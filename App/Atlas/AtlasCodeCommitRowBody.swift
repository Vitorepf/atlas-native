import SwiftUI
import AtlasCore

// AtlasCodeCommitRow body — chrome · meta · face (WAVE-054)


extension AtlasCodeCommitRow {
    var commitRowA11yChrome: some View {
        CommitRowAskChrome(
            isDimmed: isDimmed,
            reduceMotion: reduceMotion,
            label: { commitRowLabel },
            accessibilityLabel: AtlasCodeCommitRowJudgment.spokenCommitRow(
                node: node, state: state, trunk: trunk, ruleId: ruleId, isDimmed: isDimmed
            ),
            accessibilityHint: commitAccessibilityHint,
            accessibilityID: A11yID.codeCommit(hashPrefix: String(node.hash.prefix(8))),
            onTap: onTap,
            onLongPress: commitLongPress,
            onAsk: onAsk
        )
    }
}

private struct CommitRowAskChrome<Label: View>: View {
    let isDimmed: Bool
    let reduceMotion: Bool
    @ViewBuilder let label: () -> Label
    let accessibilityLabel: String
    let accessibilityHint: String
    let accessibilityID: String
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onAsk: (() -> Void)?

    @State private var offset: CGFloat = 0
    /// Evita que o fim do swipe dispare o Button (proveniência).
    @State private var suppressTap = false

    var body: some View {
        Button {
            guard !suppressTap else { return }
            onTap()
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .offset(x: offset)
        .opacity(isDimmed ? 0.26 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: isDimmed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityIdentifier(accessibilityID)
        .onLongPressGesture(minimumDuration: 0.45, perform: onLongPress)
        .simultaneousGesture(askDrag)
    }

    private var askDrag: some Gesture {
        DragGesture(minimumDistance: 28)
            .onChanged { value in
                guard onAsk != nil else { return }
                let dx = value.translation.width
                let dy = value.translation.height
                guard abs(dx) > abs(dy), dx < 0 else { return }
                offset = max(dx, -72)
            }
            .onEnded { value in
                guard onAsk != nil else {
                    offset = 0
                    return
                }
                let shouldAsk = value.translation.width < -56
                let reset = { offset = 0 }
                if reduceMotion {
                    reset()
                } else {
                    withAnimation(.easeOut(duration: 0.18), reset)
                }
                guard shouldAsk else { return }
                suppressTap = true
                onAsk?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    suppressTap = false
                }
            }
    }
}


extension AtlasCodeCommitRow {
    /// WAVE-054: tip/display from CommitRowJudgment (pure).
    static func tipBranch(from refs: [String], excluding: String?) -> String? {
        AtlasCodeCommitRowJudgment.tipBranch(from: refs, excluding: excluding)
    }

    var rowFace: AtlasCodeCommitRowFace {
        AtlasCodeCommitRowJudgment.face(state: state, isDimmed: isDimmed)
    }

    var displayBranch: String {
        AtlasCodeCommitRowJudgment.displayBranch(node: node, state: state, trunk: trunk)
    }

    var displayAuthor: String {
        AtlasCodeCommitRowJudgment.displayAuthor(node: node)
    }
}

extension AtlasCodeCommitRow {
    /// Manchete: mensagem completa (tipo vive aqui). Sem mensagem → hash.
    var titleText: String {
        guard let message = node.message, !message.isEmpty else {
            return String(node.hash.prefix(8))
        }
        return message
    }
}

extension AtlasCodeCommitRow {
    var commitAccessibilityHint: String {
        guard !isDimmed else { return "" }
        if onAsk != nil {
            return "abre proveniência; arraste para a esquerda para usar na pílula"
        }
        if onLongPress != nil { return "abre proveniência do commit; pressione e segure para opções" }
        return "abre proveniência do commit"
    }
}

extension AtlasCodeCommitRow {
    var commitRowTextStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleText)
                .atlasSans(14, .medium)
                .foregroundStyle(state == .violating ? color : AtlasTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .accessibilityHidden(true)
            commitMetaLine
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, isFirst ? 4 : 0)
        .padding(.horizontal, isFirst ? 8 : 0)
        .background {
            if isFirst {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AtlasTheme.accent.opacity(0.07), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
    }
}

extension AtlasCodeCommitRow {
    var commitRowLabel: some View {
        HStack(alignment: .top, spacing: 12) {
            spine
            commitRowTextStack
            Spacer(minLength: 0)
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }
}

extension AtlasCodeCommitRow {
    func commitLongPress() {
        onLongPress?()
    }
}

extension AtlasCodeCommitRow {
    @ViewBuilder
    var commitMetaAuthorTime: some View {
        Text(displayBranch)
            .foregroundStyle(branchMetaColor)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(displayAuthor)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityHidden(true)
        Text("·")
            .accessibilityHidden(true)
        Text(AtlasCodeRelativeTime.short(from: node.authoredAt))
            .accessibilityHidden(true)
    }

    private var branchMetaColor: Color {
        // WAVE-054: meta tint from Judgment.
        AtlasCodeCommitRowJudgment.branchMetaColor(for: state)
    }
}

extension AtlasCodeCommitRow {
    var commitMetaLine: some View {
        HStack(spacing: 6) {
            commitMetaAuthorTime
            if let ruleId {
                Text("·")
                    .accessibilityHidden(true)
                Text(AtlasCodeIssue.law(ruleId, trunk: trunk))
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
            }
        }
        .font(AtlasFont.mono(9))
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension View {
    /// Silencia conectores e nó; VoiceOver só ouve a linha do commit.
    func atlasCodeGraphSpineDecorative() -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
    }
}

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumnConnectors(spineTint: Color, motion: Animation?) -> some View {
        let lane = AtlasCodeGraphLane.index(for: state)
        let above = AtlasCodeGraphLane.index(for: aboveState ?? .onMain)
        let below = AtlasCodeGraphLane.index(for: belowState ?? .onMain)
        let trunkX = AtlasCodeGraphLane.base
        let sideX = AtlasCodeGraphLane.sideX
        let laneX = AtlasCodeGraphLane.x(lane: lane)
        let nodeY = AtlasCodeGraphLane.nodeCenterY

        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                let h = max(size.height, nodeY + 12)
                strokeTrunk(context: context, trunkX: trunkX, nodeY: nodeY, h: h)

                // Origem: este ✦ é o pai — faixa está ACIMA (tip/cadeia mais nova).
                if lane == 0, above > 0, !isFirst {
                    let peel = AtlasCodeGraphLane.forkPath(
                        from: CGPoint(x: trunkX, y: nodeY),
                        to: CGPoint(x: sideX, y: 0)
                    )
                    context.stroke(
                        peel,
                        with: .color(peelColorTowardAbove.opacity(0.92)),
                        lineWidth: AtlasCodeGraphLane.sideWidth
                    )
                }

                guard lane > 0 else { return }

                let stroke = sideStrokeColor

                // Chega de cima (cadeia na mesma faixa).
                if above > 0, !isFirst {
                    var up = Path()
                    up.move(to: CGPoint(x: sideX, y: 0))
                    up.addLine(to: CGPoint(x: sideX, y: nodeY))
                    context.stroke(up, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                }

                // Chega de baixo (peel do pai na linha de baixo → nosso rodapé).
                if below == 0, !isLast {
                    var fromParent = Path()
                    fromParent.move(to: CGPoint(x: sideX, y: h))
                    fromParent.addLine(to: CGPoint(x: sideX, y: nodeY))
                    context.stroke(fromParent, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                } else if below > 0, !isLast {
                    var down = Path()
                    down.move(to: CGPoint(x: sideX, y: nodeY))
                    down.addLine(to: CGPoint(x: sideX, y: h))
                    context.stroke(down, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                } else if isLast {
                    // Sem pai na lista: elbow no próprio tip (única âncora possível).
                    let elbow = AtlasCodeGraphLane.forkPath(
                        from: CGPoint(x: trunkX, y: nodeY),
                        to: CGPoint(x: sideX, y: nodeY)
                    )
                    context.stroke(elbow, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                }
            }
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Color.clear.frame(height: max(0, nodeY - 11))
                HStack(spacing: 0) {
                    Color.clear.frame(width: max(0, laneX - 11))
                    spineNode(motion: motion)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func strokeTrunk(
        context: GraphicsContext,
        trunkX: CGFloat,
        nodeY: CGFloat,
        h: CGFloat
    ) {
        var trunk = Path()
        let top: CGFloat = isFirst ? nodeY : 0
        let bot: CGFloat = isLast ? nodeY : h
        guard bot > top else { return }
        trunk.move(to: CGPoint(x: trunkX, y: top))
        trunk.addLine(to: CGPoint(x: trunkX, y: bot))
        context.stroke(
            trunk,
            with: .color(AtlasTheme.accent.opacity(0.42)),
            lineWidth: AtlasCodeGraphLane.trunkWidth
        )
    }

    private var sideStrokeColor: Color {
        color.opacity(state == .history ? 0.5 : 0.92)
    }

    private var peelColorTowardAbove: Color {
        guard let aboveState else { return AtlasCodePalette.alert }
        return AtlasCodePalette.color(for: aboveState)
    }
}

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumnFrame<Content: View>(_ content: Content, motion: Animation?) -> some View {
        content
            .frame(width: AtlasCodeGraphLane.gutter)
            .frame(minHeight: 44)
            .animation(motion, value: state)
            .animation(motion, value: isFirst)
            .animation(motion, value: isLast)
            .atlasCodeGraphSpineDecorative()
    }
}

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumn(spineTint: Color, motion: Animation?) -> some View {
        spineColumnFrame(
            spineColumnConnectors(spineTint: spineTint, motion: motion),
            motion: motion
        )
    }
}

extension AtlasCodeCommitRow {
    /// Linha contínua + nó. Cor via `AtlasCodePalette` (contrato); sem spoken.
    @ViewBuilder
    var spine: some View {
        let spineTint = color.opacity(0.45)
        let motion = AtlasMotionPresentation.editorial(reduceMotion: reduceMotion)
        spineColumn(spineTint: spineTint, motion: motion)
    }
}

extension AtlasCodeCommitRow {
    @ViewBuilder
    var spineCoreDot: some View {
        switch state {
        case .onMain, .healed:
            Text("✦")
                .font(AtlasFont.serif(state == .onMain && !isFirst ? 11 : 13))
                .foregroundStyle(color)
                .shadow(color: color.opacity(isFirst ? 0.45 : 0.25), radius: isFirst ? 5 : 3, y: 0)
                .accessibilityHidden(true)
        case .violating, .history:
            let d = AtlasCodeGraphLane.nodeRadius * 2
            Circle()
                .fill(color)
                .frame(width: d, height: d)
                .overlay(
                    Circle()
                        .strokeBorder(AtlasTheme.bg, lineWidth: 2)
                        .frame(width: d + 3, height: d + 3)
                )
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineViolatingRing(motion: Animation?) -> some View {
        EmptyView()
    }
}

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineNode(motion: Animation?) -> some View {
        ZStack {
            spineViolatingRing(motion: motion)
            spineCoreDot
        }
        .frame(width: 22, height: 22)
        .animation(motion, value: state == .violating)
    }
}

extension AtlasCodeCommitRow {
    func spineConnector(fill: Color) -> some View {
        Rectangle()
            .fill(fill)
            .frame(width: 2)
            .accessibilityHidden(true)
    }
}

