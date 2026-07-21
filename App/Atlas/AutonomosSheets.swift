import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Autonomos sheets fused

// MARK: - New sheet

struct AutonomosNewSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var name = ""
    @State private var charter = ""
    let onCreate: (String, String) -> Void
    let onCancel: () -> Void

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AutonomosMapChrome.heroTitle("Novo Autônomo", size: 28)
                    Text("Um escopo fechado. Fica neste iPhone até o create no servidor existir.")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    field(
                        label: "Nome",
                        placeholder: "ex.: Agente iOS Dinheiro",
                        text: $name,
                        axis: .horizontal
                    )
                    field(
                        label: "Carta",
                        placeholder: "O que este Autônomo pode e não pode tocar.",
                        text: $charter,
                        axis: .vertical
                    )

                    AutonomosMapChrome.primaryCTA("Guardar neste iPhone", enabled: canCreate) {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onCreate(name, charter)
                    }
                    Text("Não publica frota no servidor. Some se o app for morto.")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    AutonomosMapChrome.quietCTA("Cancelar", action: onCancel)
                }
                .padding(AtlasTheme.Space.screen)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func field(
        label: String,
        placeholder: String,
        text: Binding<String>,
        axis: Axis
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
            Group {
                if axis == .vertical {
                    TextField(placeholder, text: text, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .font(AtlasFont.serif(17))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(AtlasTheme.bgRecessed, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .strokeBorder(AtlasTheme.separator.opacity(0.55), lineWidth: 1)
            )
        }
    }
}

// MARK: - Reason sheet

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
