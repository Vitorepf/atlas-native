import Foundation
import AtlasCore

/// Control error spoken — peel de AutonomosLoadedSection+A11yControl.

enum AutonomosLoadedSectionA11yControlError {
    static func spokenControlError(_ message: String) -> String {
        "erro de controle, \(message)"
    }
}
