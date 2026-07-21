import SwiftUI

/// Folha padrão de governança: quem autoriza + motivo auditável (WAVE-098 Judgment).
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var actor = ""
    @State private var reason: String

    init(
        title: String,
        explainer: String,
        reasonOptional: Bool = false,
        initialReason: String = "",
        onConfirm: @escaping (String, String) -> Void
    ) {
        self.title = title
        self.explainer = explainer
        self.reasonOptional = reasonOptional
        self.onConfirm = onConfirm
        _reason = State(initialValue: initialReason)
    }

    private var reasonFace: AutonomosReasonFace {
        AutonomosReasonJudgment.face(
            actor: actor, reason: reason, reasonOptional: reasonOptional
        )
    }

    private var canSubmit: Bool {
        AutonomosReasonJudgment.canSubmit(
            actor: actor, reason: reason, reasonOptional: reasonOptional
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(AutonomosReasonJudgment.sectionAction) {
                    Text(title).accessibilityAddTraits(.isHeader)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section(AutonomosReasonJudgment.sectionOperator) {
                    TextField(AutonomosReasonJudgment.actorPlaceholder, text: $actor)
                        .accessibilityIdentifier(A11yID.autonomosReasonActor)
                        .accessibilityHint(AutonomosReasonJudgment.actorHint)
                }
                Section(AutonomosReasonJudgment.reasonSectionTitle(reasonOptional: reasonOptional)) {
                    TextField(
                        AutonomosReasonJudgment.reasonPlaceholder,
                        text: $reason,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .accessibilityIdentifier(A11yID.autonomosReasonField)
                    .accessibilityHint(
                        AutonomosReasonJudgment.reasonFieldHint(reasonOptional: reasonOptional)
                    )
                }
            }
            .navigationTitle(AutonomosReasonJudgment.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        title: AutonomosReasonJudgment.cancelTitle,
                        spokenLabel: AutonomosReasonJudgment.cancelSpoken,
                        spokenHint: AutonomosReasonJudgment.cancelHint,
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AutonomosReasonJudgment.confirmTitle) {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onConfirm(actor, reason)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                    .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
                    .accessibilityLabel(
                        AutonomosReasonJudgment.spokenConfirm(
                            actionTitle: title,
                            actor: actor,
                            reason: reason,
                            reasonOptional: reasonOptional
                        )
                    )
                    .accessibilityValue(reasonFace.productWord)
                }
            }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            .accessibilityLabel(AutonomosReasonJudgment.spokenSheet(actionTitle: title))
            .accessibilityValue(reasonFace.productWord)
        }
    }
}
