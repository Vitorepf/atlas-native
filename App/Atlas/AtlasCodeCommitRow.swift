import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused

// --- AtlasCodeCommitRow.swift ---
// MARK: - Linha do commit (mensagem é a manchete)
// Label → AtlasCodeCommitRow+Label.swift · Spine → +Spine.swift
// LongPress → AtlasCodeCommitRow+LongPress.swift
// A11y chrome → AtlasCodeCommitRow+A11yChrome.swift

struct AtlasCodeCommitRow: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// A trunk real: a lei na linha fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let isFirst: Bool
    let isLast: Bool
    /// Estado do vizinho acima/abaixo no filtro atual — continuidade da lane.
    var aboveState: AtlasCodeNodeState? = nil
    var belowState: AtlasCodeNodeState? = nil
    /// A pílula respondeu e este commit não está na resposta: ele recua, mas
    /// nunca some — esconder história para responder uma pergunta seria mentir
    /// sobre o repositório.
    var isDimmed: Bool = false
    let onTap: () -> Void
    var onLongPress: (() -> Void)? = nil
    /// Arrastar → pílula/ask com este commit como contexto.
    var onAsk: (() -> Void)? = nil

    var color: Color { AtlasCodePalette.color(for: state) }

    var body: some View {
        commitRowA11yChrome
    }
}

