import SwiftUI
import AtlasCore

// Schedule title — peel de AutonomosDigestSection+ScheduleCopy.

extension AutonomosNextDigestSection {
    var sectionTitle: String {
        digest.nextDigestAt?.nonEmpty != nil ? "PRÓXIMO RESUMO" : "RESUMO GOVERNADO"
    }
}
