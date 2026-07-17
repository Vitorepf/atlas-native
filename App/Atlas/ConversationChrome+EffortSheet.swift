import SwiftUI
import UIKit
import AtlasCore

// Pick → ConversationChrome+EffortSheet+Pick.swift
// Rows → ConversationChrome+EffortSheet+Rows.swift
struct EffortSheet: View {
    var model: ConversationModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        effortA11yBind(
            SheetShell(title: "Esforço") {
                effortSheetContent
            }
        )
    }
}
