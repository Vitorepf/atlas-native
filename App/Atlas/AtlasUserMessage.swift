import Foundation
import AtlasCore

/// Mensagens de erro amigáveis partilhadas entre models da casca.
func atlasUserMessage(for error: Error) -> String {
    if error is AtlasInteractionStreamError {
        return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
    }
    if let urlError = error as? URLError {
        switch urlError.code {
        case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
             .cannotFindHost, .timedOut:
            return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
        default:
            return "Não foi possível falar com o Atlas agora. Tente novamente."
        }
    }
    if let api = error as? AtlasApiError {
        switch api.status {
        case 401, 403: return "A sessão do Atlas precisa ser reconectada."
        case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
        case 500...599: return "O servidor Atlas está temporariamente indisponível."
        default: return api.message
        }
    }
    return "A execução foi interrompida. Tente novamente."
}
