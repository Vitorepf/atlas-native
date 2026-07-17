import Foundation

/// Accept/dismiss spoken — peel de NightlyProposal+A11y.

extension NightlyProposalCard {
    static func spokenAcceptLabel() -> String { "preparar missão noturna" }

    static func spokenAcceptHint() -> String {
        "abre o ensaio governado da missão noturna"
    }

    static func spokenDismissLabel() -> String { "hoje não" }

    static func spokenDismissHint() -> String {
        "descarta a proposta em silêncio, sem confirmação"
    }
}
