import Foundation

/// Copy de notificações noturnas/matinais — peel de NightlyProposal (CICLO C residual honesty).

extension NightlyProposalController {
    enum NotificationCopy {
        static let nightlyTitle = "A frota pode trabalhar esta noite"

        static func nightlyBody(workspaces: [String]) -> String {
            "Hoje você mexeu em \(workspaces.joined(separator: ", ")). "
                + "Quer pôr os Autônomos nisso enquanto descansa?"
        }

        /// Manhã: convite sem afirmar entrega — fatos só no digest em Autônomos.
        static let morningTitle = "Resumo da missão noturna"
        static let morningBody = "Abra Autônomos para ver o que a frota entregou com prova."
    }
}
