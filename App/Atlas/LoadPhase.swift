import Foundation

/// Fase de carregamento compartilhada pelos models de leitura da casca.
/// ConversationModel fica fora — estado mais rico, não force-fit.
enum LoadPhase: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
