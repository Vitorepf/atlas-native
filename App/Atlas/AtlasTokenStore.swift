import Foundation
import Security

enum AtlasTokenStore {
    private static let service = "com.vitor.atlas.native"
    private static let account = "ATLAS_TOKEN"

    static func resolve(configuredToken: String) -> String {
        let trimmed = configuredToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            save(trimmed)
            return trimmed
        }
        return load() ?? ""
    }

    private static func load() -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty else { return nil }
        return token
    }

    private static func save(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        var query = baseQuery()
        let attributes = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            _ = SecItemAdd(query as CFDictionary, nil)
        }
    }

    private static func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
