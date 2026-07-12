import Foundation

/// An entity keyed by a stable client-generated id, carrying LWW + tombstone metadata.
/// Mirrors the shape every `merge*` function in `lib/storeConverters.ts` relies on.
public protocol ClientMergeable {
    var clientId: String { get }
    var updatedAt: String { get }
    /// `nil` OR empty string means "not deleted" — the TS uses a JS truthy check
    /// (`if (item.deleted_at)`), and `""` is falsy in JS.
    var deletedAt: String? { get }
}

public enum Merge {
    /// Client-id-keyed Last-Write-Wins with tombstones, then a stable descending sort.
    /// This is the correctness core — a verbatim behavioural port of the `merge*`
    /// functions in `lib/storeConverters.ts`:
    ///
    /// ```js
    /// for (const item of items) {
    ///   if (item.deleted_at) { byClientId.delete(item.client_id); continue }
    ///   const existing = byClientId.get(item.client_id)
    ///   if (!existing || new Date(item.updated_at).getTime() >= new Date(existing.updated_at).getTime())
    ///     byClientId.set(item.client_id, item)
    /// }
    /// return [...byClientId.values()].sort((a,b) => key(b) - key(a))
    /// ```
    ///
    /// Faithful details that matter:
    /// - **Tombstone is a truthy check**: a non-empty `deletedAt` removes the id;
    ///   `nil` or `""` does not (JS `""` is falsy).
    /// - **`>=` favours the later item on ties** (equal `updatedAt` → last one seen wins).
    /// - **NaN timestamps never win**: `new Date(bad).getTime()` is `NaN`, and every
    ///   `NaN >= x` / `x >= NaN` is `false`, so a bad `updatedAt` keeps the existing value.
    ///   `Double.nan` in Swift has the identical comparison semantics.
    /// - **JS `Map` insertion order**: a key's slot is fixed on first insert, preserved
    ///   on overwrite, and reset if deleted then re-added. We track that so the final
    ///   sort is stable in the same order JS's stable sort would produce.
    public static func byClientId<T: ClientMergeable>(
        _ items: [T],
        sortDescendingBy sortKey: (T) -> Double
    ) -> [T] {
        var byClientId: [String: T] = [:]
        var slot: [String: Int] = [:]   // client_id -> JS-Map insertion slot
        var counter = 0

        for item in items {
            if let deleted = item.deletedAt, !deleted.isEmpty {
                byClientId.removeValue(forKey: item.clientId)
                slot.removeValue(forKey: item.clientId)
                continue
            }
            let existing = byClientId[item.clientId]
            if existing == nil || AtlasTime.ms(item.updatedAt) >= AtlasTime.ms(existing!.updatedAt) {
                if byClientId[item.clientId] == nil {
                    slot[item.clientId] = counter
                    counter += 1
                }
                byClientId[item.clientId] = item
            }
        }

        // Values in JS-Map insertion order, then a STABLE descending sort by the domain key.
        let inInsertionOrder = byClientId.keys
            .sorted { slot[$0]! < slot[$1]! }
            .map { byClientId[$0]! }

        return inInsertionOrder
            .enumerated()
            .sorted { a, b in
                let ka = sortKey(a.element), kb = sortKey(b.element)
                if ka == kb { return a.offset < b.offset }   // stable tie-break = insertion order
                return ka > kb
            }
            .map { $0.element }
    }
}
