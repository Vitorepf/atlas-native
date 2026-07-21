import SwiftUI
import AtlasCore

// Cycle 021 fuse → ConversationChrome+EffortSheet.swift

extension ComposerSheetA11y {
    static func effortLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenEffort(effort)), \(state)"
    }
}

extension ComposerSheetA11y {
    static func spokenEffortLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "esforço automático"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        default: return nil
        }
    }
}

extension ComposerSheetA11y {
    static func spokenEffort(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLight(effort) { return light }
        switch effort {
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        default: return "esforço automático"
        }
    }
}

extension ComposerSheetA11y {
    static func effortSubtitleLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        default: return nil
        }
    }
}

extension ComposerSheetA11y {
    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        if let light = effortSubtitleLight(effort) { return light }
        switch effort {
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        default: return "Atlas Decide escolhe; nada vai no payload"
        }
    }
}

extension EffortSheet {
    func effortA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.effortSheet)
            .accessibilityLabel("esforço computacional")
            .accessibilityHint(ComposerSheetA11y.effortSheetHint)
    }
}

extension EffortSheet {
    var effortFootnoteCopy: some View {
        Text("vale para o próximo envio; automático deixa o Atlas Decide escolher")
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

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
