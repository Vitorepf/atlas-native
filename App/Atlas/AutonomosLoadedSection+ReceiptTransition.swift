import SwiftUI
import AtlasCore

// Receipt transition — peel de AutonomosLoadedSection+ReceiptLines.

extension AutonomosRunReceiptLines {
    var receiptTransition: AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .offset(y: 6))
    }
}
