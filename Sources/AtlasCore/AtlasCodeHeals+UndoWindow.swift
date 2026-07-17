import Foundation

/// O relógio do veto — peel de AtlasCodeHeals.
///
/// O canon do operador é autonomia > aprovação: o Atlas age sozinho e o humano
/// tem VETO RETROATIVO com recibo. Esse veto é a única coisa que ele pode
/// fazer, e ela tem prazo: o servidor grava `undo_expires_at` em todo recibo
/// (30 dias) e RECUSA de verdade depois disso (`heal_undo_expired`).
public enum AtlasCodeUndoWindow {
    /// Estado do veto agora. `nil` de prazo = recibo sem janela declarada (o
    /// servidor não prometeu prazo): o botão vale, e o servidor é a autoridade
    /// se recusar — nunca inventamos um prazo que ninguém prometeu.
    public static func isOpen(expiresAt: String?, now: Date = Date()) -> Bool {
        guard let deadline = date(expiresAt) else { return true }
        return deadline > now
    }

    /// "desfazível até 14 de agosto" — a frase que faltava.
    public static func note(expiresAt: String?, now: Date = Date()) -> String? {
        guard let deadline = date(expiresAt) else { return nil }
        if deadline <= now { return "o prazo de veto venceu" }

        let formatador = DateFormatter()
        formatador.locale = Locale(identifier: "pt_BR")
        formatador.dateFormat = "d 'de' MMMM"
        return "desfazível até \(formatador.string(from: deadline))"
    }

    private static func date(_ raw: String?) -> Date? {
        guard let raw, !raw.isEmpty else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: raw) { return d }
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.date(from: raw)
    }
}
