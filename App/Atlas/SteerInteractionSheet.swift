import SwiftUI
import AtlasCore

// IDLE-COMPRESS host

// --- SteerInteractionSheet.swift ---
struct SteerInteractionSheet: View {
    let traceId: TraceID
    var model: ConversationModel
    let onSubmit: (String, AtlasInteractionSteerScope) -> Void

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var instruction = ""
    @State var scope: AtlasInteractionSteerScope = .currentStep

    var body: some View {
        steerA11yShell(steerNavigationStack)
    }
}

