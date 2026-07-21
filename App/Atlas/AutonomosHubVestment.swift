import Foundation

/// Vestimenta do hub de um Autônomo soberano (v9) — só quiet/live do catálogo local.
/// Contagens de backlog/decisão do motor não mentem presença sem a face de decisão.
enum AutonomosHubVestment: Equatable {
    case live
    case quiet
}
