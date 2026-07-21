import AtlasCore
import Foundation

// IDLE-COMPRESS fused

// --- AtlasUserMessage+API.swift ---
func atlasUserMessage(forAPI error: Error) -> String? {
    guard let api = error as? AtlasApiError else { return nil }
    switch api.status {
    case 401, 403: return "A sessão do Atlas precisa ser reconectada."
    case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
    case 500...599: return "O servidor Atlas está temporariamente indisponível."
    default: return api.message
    }
}

// --- AtlasUserMessage+Stream.swift ---
func atlasUserMessage(forStream error: Error) -> String? {
    guard error is AtlasInteractionStreamError else { return nil }
    return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
}

// --- AtlasUserMessage+URL.swift ---
func atlasUserMessage(forURL error: Error) -> String? {
    guard let urlError = error as? URLError else { return nil }
    switch urlError.code {
    case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
         .cannotFindHost, .timedOut:
        return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
    default:
        return "Não foi possível falar com o Atlas agora. Tente novamente."
    }
}

// --- AtlasUserMessage.swift ---
func atlasUserMessage(for error: Error) -> String {
    if let message = atlasUserMessage(forStream: error) { return message }
    if let message = atlasUserMessage(forURL: error) { return message }
    if let message = atlasUserMessage(forAPI: error) { return message }
    return "A execução foi interrompida. Tente novamente."
}
