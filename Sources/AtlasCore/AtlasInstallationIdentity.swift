import Foundation

/// Identidade opaca por instalação. Não é conta, dispositivo físico nem token
/// Atlas: só separa fila/upload/presença entre instalações locais.
public enum AtlasInstallationIdentity {
    public static let id: String = {
        let key = "atlas.install.salt"
        if let value = UserDefaults.standard.string(forKey: key), !value.isEmpty { return value }
        let value = UUID().uuidString
        UserDefaults.standard.set(value, forKey: key)
        return value
    }()
}
