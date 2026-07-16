import Foundation

extension KeyedDecodingContainer {
    /// Fail-closed: schema desconhecido derruba o decode inteiro (lei do repo).
    func requireSchema(_ expected: String, forKey key: Key, message: String) throws -> String {
        let schemaVersion = try decode(String.self, forKey: key)
        guard schemaVersion == expected else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: message
            )
        }
        return schemaVersion
    }
}
