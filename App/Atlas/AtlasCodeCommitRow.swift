import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: CommitRow + Meta fused

// MARK: - Row

// MARK: - Host

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

// MARK: - Body

// MARK: - Host

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

// MARK: - Helpers

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

// MARK: - Meta

// MARK: - Meta line
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
// MARK: - Spine decorative
    func atlasCodeGraphSpineDecorative() -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
    }
}

// MARK: - Spine connectors
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

// MARK: - File row

// MARK: - Host

struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange
    var accessibilityIdentifier: String?

    var body: some View {
        lead
            .padding(.vertical, 9)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AtlasCodeProvenanceJudgment.spokenFile(file))
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

// MARK: - Body

extension AtlasCodeFileRow {
    var lead: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: symbol)
                .atlasSans(8.5, .bold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 17, height: 17)
                .background(AtlasTheme.surfaceHi, in: RoundedRectangle(cornerRadius: 5))
                .accessibilityHidden(true)

            fileNameStack

            Spacer(minLength: 8)

            diffStats
        }
    }
}

extension AtlasCodeFileRow {
    var fileNameStack: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(file.fileName)
                .atlasSans(12.5, .medium)
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            if let subtitle {
                Text(subtitle)
                    .font(AtlasFont.mono(8.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
        }
        .accessibilityHidden(true)
    }
}

extension AtlasCodeFileRow {
    var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }
}

extension AtlasCodeFileRow {
    var symbolMutate: String? {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        default: return nil
        }
    }
}

extension AtlasCodeFileRow {
    var symbolTransform: String? {
        switch file.status {
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        default: return nil
        }
    }
}

extension AtlasCodeFileRow {
    var symbol: String {
        symbolMutate ?? symbolTransform ?? "questionmark"
    }
}

extension AtlasCodeFileRow {
    @ViewBuilder
    var diffStats: some View {
        if let additions = file.additions, let deletions = file.deletions {
            Text("+\(additions) \u{2212}\(deletions)")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        } else {
            Text("binário")
                .font(AtlasFont.mono(8.5))
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                .accessibilityHidden(true)
        }
    }
}

// MARK: - AtlasCodeCommitRowJudgment

// MARK: - Types

/// Exclusive commit-row face (WAVE-054). Dim elevates over node state.
enum AtlasCodeCommitRowFace: Equatable {
    case dimmed
    case violating
    case healed
    case onMain
    case history

    var productWord: String {
        switch self {
        case .dimmed: return "dimmed"
        case .violating: return "fora"
        case .healed: return "curados"
        case .onMain: return "main"
        case .history: return "história"
        }
    }

    var spokenFace: String {
        switch self {
        case .dimmed: return "fora da resposta da pílula"
        case .violating: return "fora da linha"
        case .healed: return "curado"
        case .onMain: return "na linha principal"
        case .history: return "história"
        }
    }
}

// MARK: - Judgment

/// Pure commit-row grammar — face · tip branch · meta color · pack helpers.
enum AtlasCodeCommitRowJudgment {

    static func face(
        state: AtlasCodeNodeState,
        isDimmed: Bool
    ) -> AtlasCodeCommitRowFace {
        if isDimmed { return .dimmed }
        switch state {
        case .violating: return .violating
        case .healed: return .healed
        case .onMain: return .onMain
        case .history: return .history
        }
    }

    /// Align non-dim product words with graph judgment vocabulary.
    static func productWord(
        state: AtlasCodeNodeState,
        isDimmed: Bool
    ) -> String {
        face(state: state, isDimmed: isDimmed).productWord
    }

    static func branchMetaColor(for state: AtlasCodeNodeState) -> Color {
        switch state {
        case .violating: return AtlasCodePalette.alert
        case .onMain, .healed: return AtlasTheme.accent
        case .history: return AtlasTheme.prussian
        }
    }

    /// Branch tip published on node refs; pure parse (no invent).
    static func tipBranch(from refs: [String], excluding: String?) -> String? {
        for ref in refs {
            let name = ref
                .replacingOccurrences(of: "HEAD -> ", with: "")
                .replacingOccurrences(of: "origin/", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if name.isEmpty || name == "HEAD" { continue }
            if let excluding, name == excluding { continue }
            return name
        }
        return nil
    }

    static func displayBranch(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?
    ) -> String {
        if let tip = tipBranch(from: node.refs, excluding: trunk) {
            return tip
        }
        if let tip = tipBranch(from: node.refs, excluding: nil) {
            return tip
        }
        if state == .onMain || state == .healed {
            return trunk ?? "main"
        }
        return trunk ?? "—"
    }

    static func displayAuthor(node: AtlasCodeGraphNode) -> String {
        if !node.authorName.isEmpty { return node.authorName }
        if !node.authorEmail.isEmpty { return node.authorEmail }
        return "—"
    }

    static func packFacts(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        isDimmed: Bool,
        trunk: String?,
        ruleId: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(state: state, isDimmed: isDimmed)
        facts.append("commit_row_face: \(face.productWord)")
        facts.append("commit: \(String(node.hash.prefix(7)))")
        facts.append("branch: \(displayBranch(node: node, state: state, trunk: trunk))")
        if let message = node.message, !message.isEmpty {
            let snip = message.count <= 72 ? message : String(message.prefix(71)) + "…"
            facts.append("subject: \(snip)")
        } else {
            absences.append("mensagem de commit ausente")
        }
        if let ruleId {
            facts.append("rule: \(ruleId)")
        }
        if isDimmed {
            facts.append("dimmed: true")
        }
        return (facts, absences)
    }

    // MARK: Spoken row (IDLE · was AtlasCodeCommitRowA11y)

    static func spokenCommitRow(
        node: AtlasCodeGraphNode,
        state: AtlasCodeNodeState,
        trunk: String?,
        ruleId: String?,
        isDimmed: Bool
    ) -> String {
        let identity = spokenIdentity(node: node, trunk: trunk)
        var parts = spokenStateParts(
            title: identity.title,
            author: identity.author,
            linha: identity.linha,
            state: state,
            ruleId: ruleId,
            trunk: trunk
        )
        parts.append(contentsOf: spokenCommitTail(authoredAt: node.authoredAt, isDimmed: isDimmed))
        return parts.joined(separator: ", ")
    }

    static func spokenIdentity(
        node: AtlasCodeGraphNode,
        trunk: String?
    ) -> (title: String, author: String, linha: String) {
        // VoiceOver lidera pelo TIPO (só a palavra) e depois a frase.
        let title: String
        if let message = node.message {
            let parsed = AtlasConventionalCommit.split(message)
            let typeWord = parsed.type.map { String($0.prefix { $0.isLetter }) }
            title = typeWord.map { "\($0), \(parsed.subject)" } ?? parsed.subject
        } else {
            title = String(node.hash.prefix(8))
        }
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        let linha = trunk?.nonEmpty ?? "linha principal"
        return (title, author, linha)
    }

    static func spokenCommitTail(authoredAt: Int, isDimmed: Bool) -> [String] {
        var parts: [String] = []
        let when = AtlasCodeRelativeTime.short(from: authoredAt)
        if !when.isEmpty { parts.append("há \(when)") }
        if isDimmed { parts.append("fora da resposta") }
        return parts
    }

    static func spokenStateParts(
        title: String,
        author: String,
        linha: String,
        state: AtlasCodeNodeState,
        ruleId: String?,
        trunk: String?
    ) -> [String] {
        switch state {
        case .violating:
            var parts = [title, "por \(author)", "fora da \(linha)"]
            if let ruleId { parts.append(AtlasCodeIssue.law(ruleId, trunk: trunk)) }
            return parts
        case .healed:
            return [title, "por \(author)", "curado"]
        case .onMain:
            return [title, "por \(author)", "na \(linha)"]
        case .history:
            return [title, "por \(author)", "história"]
        }
    }
}
