import SwiftUI
import AtlasCore
import PhotosUI

// IDLE-COMPRESS peel EffortSheet + SheetRow + NewMarker (canon §7)


extension EffortSheet {
    func pick(_ effort: AtlasComputeEffort) {
        // Persistência é do MODEL (boundary): a View nunca toca storage.
        model.setEffort(effort)
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
    }
}

extension EffortSheet {
    var effortRows: some View {
        ForEach(AtlasComputeEffort.allCases, id: \.self) { effort in
            let selected = effort == model.effort
            SheetRow(
                label: effort.shortLabel.capitalized,
                sub: ComposerSheetA11y.effortSubtitle(effort),
                selected: selected,
                accessibilityLabel: ComposerSheetA11y.effortLabel(effort, selected: selected),
                accessibilityIdentifier: A11yID.effortRow(effort.rawValue)
            ) {
                pick(effort)
            }
        }
    }
}

extension EffortSheet {
    @ViewBuilder
    var effortSheetContent: some View {
        effortFootnoteCopy
        effortRows
    }
}

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

struct SheetRow: View {
    let label: String
    var sub: String? = nil
    let selected: Bool
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    var accessibilityIdentifier: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            rowLabel
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            accessibilityLabel ?? SheetShellA11y.spokenRow(label: label, sub: sub, selected: selected)
        )
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .modifier(OptionalAccessibilityIdentifier(id: accessibilityIdentifier))
        .overlay(alignment: .bottom) { sheetRowDivider }
    }

    var rowLabel: some View {
        HStack(spacing: 12) {
            sheetRowLeading
            Spacer()
            sheetRowTrailing
        }
        .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
    }

    var sheetRowLeading: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let sub {
                Text(sub).atlasSans(13).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    var sheetRowTrailing: some View {
        if selected {
            Image(systemName: "checkmark").atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }

    var sheetRowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
    }
}

struct OptionalAccessibilityIdentifier: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}

/// Spoken labels do shell/rows compartilhados — rótulo composto com label/sub/seleção.
enum SheetShellA11y {
    static func spokenRow(label: String, sub: String?, selected: Bool) -> String {
        var parts = [label]
        if let sub, !sub.isEmpty { parts.append(sub) }
        parts.append(selected ? "selecionado" : "disponível")
        return parts.joined(separator: ", ")
    }
}

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
            Text("NOVO DESDE ÚLTIMA VISITA")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("novo desde a última visita")
        .accessibilityAddTraits(.isStaticText)
    }
}
