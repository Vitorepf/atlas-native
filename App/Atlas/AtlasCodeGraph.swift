import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Code commit row + graph judgment fused

// MARK: - Commit row

// MARK: - Row

// MARK: - Host

// MARK: - Linha do commit (mensagem é a manchete)
// Label → AtlasCodeCommitRow+Label.swift · Spine → +Spine.swift
// LongPress → AtlasCodeCommitRow+LongPress.swift

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
        commitRowA11y
    }
}

// MARK: - Body

// MARK: - Host

extension AtlasCodeCommitRow {
    var commitRowA11y: some View {
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

/// Distância a partir da qual soltar confirma. Uma constante só: o alvo que
/// acende e o gesto que dispara precisam concordar, senão o operador vê
/// "solta que eu pergunto" e o toque não pergunta.
private let commitAskArmThreshold: CGFloat = 56

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
    /// Passou do ponto em que soltar CONFIRMA. Move o háptico e acende o alvo.
    @State private var armed = false

    var body: some View {
        Button {
            guard !suppressTap else { return }
            onTap()
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .offset(x: offset)
        // O destino vive ATRÁS da linha: arrastar revela para onde o commit
        // vai. Sem isto o gesto era cego — nada dizia o que ia acontecer.
        .background(alignment: .trailing) { askRevealTarget }
        .opacity(isDimmed ? 0.26 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: isDimmed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityIdentifier(accessibilityID)
        .onLongPressGesture(minimumDuration: 0.45, perform: onLongPress)
        .simultaneousGesture(askDrag)
    }

    /// Alvo que o arrasto revela. Apagado enquanto o gesto não chegou lá;
    /// aceso em ouro quando soltar confirma.
    @ViewBuilder
    private var askRevealTarget: some View {
        if onAsk != nil, offset < -2 {
            HStack(spacing: 6) {
                Image(systemName: armed ? "sparkles" : "arrow.left")
                    .atlasSans(12, .semibold)
                Text(armed ? "soltar pergunta" : "arraste")
                    .atlasSans(10, .medium)
                    .lineLimit(1)
            }
            .foregroundStyle(armed ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .padding(.trailing, 8)
            .opacity(min(1, Double(-offset) / Double(commitAskArmThreshold)))
            .accessibilityHidden(true)
        }
    }

    private var askDrag: some Gesture {
        DragGesture(minimumDistance: 28)
            .onChanged { value in
                guard onAsk != nil else { return }
                let dx = value.translation.width
                let dy = value.translation.height
                guard abs(dx) > abs(dy), dx < 0 else { return }
                offset = max(dx, -72)
                // O toque avisa no instante em que soltar passa a confirmar —
                // é assim que se sabe que "já deu", sem olhar.
                let nowArmed = dx < -commitAskArmThreshold
                if nowArmed != armed {
                    armed = nowArmed
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                }
            }
            .onEnded { value in
                let shouldAsk = onAsk != nil && value.translation.width < -commitAskArmThreshold
                let reset = {
                    offset = 0
                    armed = false
                }
                if reduceMotion {
                    reset()
                } else {
                    withAnimation(.easeOut(duration: 0.18), reset)
                }
                guard shouldAsk else { return }
                // Confirmou: recibo tátil distinto do de armar.
                AtlasMotion.successNotification(reduceMotion: reduceMotion)
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
                .atlasSans(15, .medium)
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
        .padding(.vertical, 8)
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

// MARK: - File row

// MARK: - Host

struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange
    var accessibilityIdentifier: String?

    var body: some View {
        lead
            .padding(.vertical, 10)
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
                    .font(AtlasFont.mono(9.5))
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
            Text(AtlasCodeGraphJudgment.productDiffStat(additions: additions, deletions: deletions))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        } else {
            Text(AtlasCodeGraphJudgment.productBinary)
                .font(AtlasFont.mono(9.5))
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

// MARK: - Graph judgment

// MARK: - Graph judgment (WAVE-028)

/// Pure commit-map judgment for single-repo grafo — parity organ with RadarJudgment.
/// Casca only; never invents dual-count or agent filter DTOs.
enum AtlasCodeGraphJudgment {

    // MARK: Default attention slice

    /// First-load attention: **fora** when violating signals exist; honest all/unknown otherwise.
    /// Operator chip override is owned by the host (`graphFilterTouchedByOperator`).
    static func defaultFilter(
        scan: AtlasCodeScanState,
        violatingSignalCount: Int
    ) -> AtlasCodeGraphStateFilter {
        switch scan {
        case .violating where violatingSignalCount > 0:
            return .violating
        case .clean, .unknown, .violating:
            return .all
        }
    }

    // MARK: Product words (align chips / spoken)

    static func productWord(for filter: AtlasCodeGraphStateFilter) -> String {
        filter.label // todos | main | fora | curados
    }

    static func productWord(for state: AtlasCodeNodeState) -> String {
        switch state {
        case .onMain: return "main"
        case .violating: return "fora"
        case .healed: return "curados"
        case .history: return "história"
        }
    }

    // MARK: Within-slice attention rank

    /// Severe-first inside current slice when scan is violating; else stable wire order.
    @MainActor
    static func rankNodes(
        _ nodes: [AtlasCodeGraphNode],
        model: AtlasCodeModel,
        scan: AtlasCodeScanState
    ) -> [AtlasCodeGraphNode] {
        guard scan == .violating else { return nodes }
        return nodes.enumerated().sorted { lhs, rhs in
            let ls = model.state(for: lhs.element)
            let rs = model.state(for: rhs.element)
            let lSevere = ls == .violating
            let rSevere = rs == .violating
            if lSevere != rSevere { return lSevere && !rSevere }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    // MARK: Pack identity (WAVE-187)

    /// Graph identity — trunk/head/commits/phase · never invents hashes.
    @MainActor
    static func packIdentityFacts(
        model: AtlasCodeModel
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []

        if let trunk = model.graph?.defaultBranch, !trunk.isEmpty {
            facts.append("graph_trunk: \(trunk)")
        } else {
            absences.append("trunk/default_branch não publicado neste load")
        }
        if let head = model.graph?.head, !head.isEmpty {
            facts.append("graph_head: \(String(head.prefix(7)))")
        }
        if let trunkHead = model.graph?.trunkHead, !trunkHead.isEmpty {
            facts.append("graph_trunk_head: \(String(trunkHead.prefix(7)))")
        }

        let nodes = model.graph?.nodes ?? []
        if !nodes.isEmpty {
            facts.append("graph_commits_loaded: \(nodes.count)")
            let violating = nodes.filter { model.state(for: $0) == .violating }.count
            facts.append("graph_sem_retorno_signals: \(violating)")
        } else {
            absences.append("grafo sem nós (load vazio ou ainda carregando)")
        }

        switch model.phase {
        case .loading, .idle:
            facts.append("graph_phase: loading")
        case .failed(let message):
            facts.append("graph_phase: failed")
            if !message.isEmpty { facts.append("graph_failure: \(message)") }
        case .loaded:
            facts.append("graph_phase: loaded")
        }

        return (facts, absences)
    }

    // MARK: Pack slice facts

    @MainActor
    static func packSliceFacts(
        model: AtlasCodeModel,
        filter: AtlasCodeGraphStateFilter
    ) -> (facts: [String], absences: [String], subjectSuffix: String) {
        var facts: [String] = []
        var absences: [String] = []

        facts.append("filter: \(productWord(for: filter))")
        facts.append("status: \(model.statusHeadline)")
        facts.append("scan: \(scanWord(model.scanState))")

        // WAVE-087: worktree face · ranked anchors (not wire dump).
        let wtPack = AtlasCodeWorktreeJudgment.packFacts(model.graph?.worktrees ?? [])
        facts.append(contentsOf: wtPack.facts)
        absences.append(contentsOf: wtPack.absences)

        let nodes = model.graph?.nodes ?? []
        if !nodes.isEmpty {
            let sliceCount = filter.count(in: nodes, model: model)
            facts.append("slice_commits: \(sliceCount)")
        }

        return (facts, absences, productWord(for: filter))
    }

    static func scanWord(_ scan: AtlasCodeScanState) -> String {
        switch scan {
        case .clean: return "clean"
        case .violating: return "violating"
        case .unknown: return "unknown"
        }
    }

    /// can_do: heal face CTA exists → local face only; never claim NL cure write.
    static func packCanDo(hasHealReceipt: Bool) -> AgenticOccasionPack.CanDo {
        hasHealReceipt ? .faceCTALocal : .readChat
    }

    static func packCanDoAbsences(hasHealReceipt: Bool) -> [String] {
        if hasHealReceipt {
            return ["cura NL via chat não autorizada — use o recibo/CTA da face (não invente mandar-curar)"]
        }
        return []
    }

    static func spokenRepoTitle(_ repo: String) -> String {
        "repositório \(repo)"
    }

    static let spokenRepoSwitcherHint = "troca de repositório"
    static let productRepoNavTitle = "Repositório"
    static let productWorktreesKicker = "WORKTREES"
    static let productQuietWeek = "semana quieta · sem commits nem curas"
    static let productBinary = "binário"
    static let productTheWeek = "A semana"
    static let productMirror = "Espelho"
    static func productDiffStat(additions: Int, deletions: Int) -> String { "+\(additions) −\(deletions)" }

    // MARK: Graph chrome spoken (IDLE · was AtlasCodeGraphA11y)

    static let productEmptyGraph = "grafo sem commits nesta janela"

    static func spokenStatus(scanState: AtlasCodeScanState, headline: String) -> String {
        switch scanState {
        case .clean, .unknown:
            return headline
        case .violating:
            return "atenção, \(headline)"
        }
    }

    static func spokenFilterChip(
        _ option: AtlasCodeGraphStateFilter,
        count: Int,
        active: Bool,
        silent: Bool
    ) -> String {
        var label = "filtrar grafo por \(option.label), \(count) commits"
        if active { label += ", selecionado" }
        if silent { label += ", nenhum commit neste filtro" }
        return label
    }
}

// MARK: - AtlasCodeWorktreeJudgment

// MARK: - Types

/// Exclusive Código graph worktrees section face (WAVE-087).
enum AtlasCodeWorktreeSectionFace: Equatable {
    case silence
    case list(Int)

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .list(let n): return "list(\(n))"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "nenhum worktree publicado"
        case .list(let n):
            let noun = n == 1 ? "worktree" : "worktrees"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure worktree strip grammar — section face · rank · chip spoken · pack.
enum AtlasCodeWorktreeJudgment {

    // MARK: Face

    static func sectionFace(_ worktrees: [AtlasCodeWorktree]) -> AtlasCodeWorktreeSectionFace {
        if worktrees.isEmpty { return .silence }
        return .list(worktrees.count)
    }

    // MARK: Rank — dirty/active first, path-stable

    /// Lower rank = more attention. Non-clean state first, then non-empty state,
    /// then pathLabel stable.
    static func attentionRank(_ worktree: AtlasCodeWorktree) -> Int {
        guard let state = worktree.state?.trimmingCharacters(in: .whitespacesAndNewlines),
              !state.isEmpty else {
            return 20
        }
        let lower = state.lowercased()
        if lower.contains("dirty") || lower.contains("modified") || lower.contains("conflict") {
            return 0
        }
        if lower.contains("active") || lower.contains("locked") {
            return 5
        }
        if lower == "clean" || lower == "pristine" {
            return 15
        }
        return 10
    }

    static func rank(_ worktrees: [AtlasCodeWorktree]) -> [AtlasCodeWorktree] {
        worktrees.enumerated().sorted { lhs, rhs in
            let lr = attentionRank(lhs.element)
            let rr = attentionRank(rhs.element)
            if lr != rr { return lr < rr }
            let lp = lhs.element.pathLabel
            let rp = rhs.element.pathLabel
            if lp != rp { return lp < rp }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    // MARK: Spoken

    static func spokenChip(_ worktree: AtlasCodeWorktree) -> String {
        var parts = [worktree.pathLabel]
        if let branch = worktree.branch?.nonEmpty {
            parts.append("branch \(branch)")
        }
        if let head = worktree.head?.nonEmpty {
            parts.append(String(head.prefix(8)))
        }
        if let state = worktree.state?.nonEmpty {
            parts.append(state)
        }
        return parts.joined(separator: ", ")
    }

    static func spokenSection(_ worktrees: [AtlasCodeWorktree]) -> String {
        let face = sectionFace(worktrees)
        guard case .list = face else { return face.spokenFace }
        let ranked = rank(worktrees)
        var parts = [face.spokenFace]
        if let head = ranked.first {
            parts.append("primeiro \(spokenChip(head))")
        }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        _ worktrees: [AtlasCodeWorktree]
    ) -> (facts: [String], absences: [String], anchors: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        var anchors: [String] = []
        let face = sectionFace(worktrees)
        facts.append("worktree_face: \(face.productWord)")
        facts.append("worktrees: \(worktrees.count)")
        switch face {
        case .silence:
            absences.append("worktrees não publicados neste load")
        case .list:
            for wt in rank(worktrees).prefix(5) {
                var line = "worktree: \(wt.pathLabel)"
                if let branch = wt.branch?.nonEmpty { line += " · \(branch)" }
                if let state = wt.state?.nonEmpty { line += " · \(state)" }
                facts.append(line)
                anchors.append(spokenChip(wt))
            }
        }
        return (facts, absences, anchors)
    }
}

// MARK: - AtlasCodeGraphLoadJudgment

// MARK: - Types

/// Exclusive código graph-screen face (WAVE-061).
enum AtlasCodeGraphScreenFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case ready(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .ready: return "ready"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "carregando"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "falha ao carregar, \(message)"
            }
            return "falha ao carregar"
        case .empty:
            return "sem commits neste recorte"
        case .ready(let n):
            return n == 1 ? "1 commit" : "\(n) commits"
        }
    }
}

// MARK: - Judgment

/// Pure graph-screen load grammar — face · spoken · pack.
enum AtlasCodeGraphLoadJudgment {

    static func face(
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil
    ) -> AtlasCodeGraphScreenFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed(let message):
            let published = failMessage ?? message
            return .failed(published.isEmpty ? nil : published)
        case .loaded:
            if nodeCount <= 0 { return .empty }
            return .ready(nodeCount)
        }
    }

    /// Screen spoken: "grafo, {repo}, {face spoken}".
    static func spokenScreen(repo: String, face: AtlasCodeGraphScreenFace) -> String {
        "grafo, \(repo), \(face.spokenFace)"
    }

    static func spokenScreen(
        repo: String,
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil
    ) -> String {
        spokenScreen(
            repo: repo,
            face: face(phase: phase, nodeCount: nodeCount, failMessage: failMessage)
        )
    }

    static func packFacts(
        repo: String,
        phase: LoadPhase,
        nodeCount: Int,
        failMessage: String? = nil,
        isAnchoring: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, nodeCount: nodeCount, failMessage: failMessage)
        facts.append("graph_screen_face: \(face.productWord)")
        facts.append("graph_repo: \(repo)")
        switch face {
        case .loading:
            absences.append("grafo ainda carregando")
        case .failed(let msg):
            absences.append("grafo falhou ao carregar")
            if let msg, !msg.isEmpty { facts.append("graph_error: \(msg)") }
        case .empty:
            absences.append("sem commits neste recorte do grafo")
            facts.append("graph_nodes: 0")
        case .ready(let n):
            facts.append("graph_nodes: \(n)")
        }
        if isAnchoring {
            facts.append("graph_anchoring: true")
        }
        return (facts, absences)
    }
}

// MARK: - AtlasCodeGraphChrome

// MARK: - Status chrome

extension AtlasCodeView {
    // MARK: Status

    @ViewBuilder
    var statusCapsule: some View {
        if let pulse = statusPulseCopy {
            Text(pulse)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(statusPulseColor)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 12)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
                .accessibilityLabel(AtlasCodeGraphJudgment.spokenStatus(
                    scanState: model.scanState, headline: pulse
                ))
                .accessibilityIdentifier(A11yID.codeStatus)
        }
    }

    var statusPulseCopy: String? {
        switch model.scanState {
        case .violating, .unknown:
            return model.statusHeadline
        case .clean:
            return nil
        }
    }

    var statusPulseColor: Color {
        switch model.scanState {
        case .violating: return AtlasCodePalette.alert
        case .unknown: return AtlasTheme.textTertiary
        case .clean: return AtlasTheme.textSecondary
        }
    }
}
// MARK: - Filter chrome

extension AtlasCodeView {
    // MARK: Filter chips

    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(AtlasCodeGraphStateFilter.grafoTabs) { option in
                let active = graphStateFilter == option
                let count = option.count(in: graph.nodes, model: model)
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        graphFilterTouchedByOperator = true
                        graphStateFilter = option
                    }
                } label: {
                    graphStateChipLabel(option, count: count, active: active)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    AtlasCodeGraphJudgment.spokenFilterChip(
                        option, count: count, active: active, silent: active && filterSilence
                    )
                )
                .accessibilityAddTraits(active ? .isSelected : [])
                .accessibilityIdentifier(A11yID.codeGraphFilter(option.rawValue))
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AtlasTheme.separator.opacity(0.85))
                .frame(height: 1)
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }

    func graphStateChipLabel(_ option: AtlasCodeGraphStateFilter, count: Int, active: Bool) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 3) {
                Text(option.label)
                    .atlasSans(12.5, .medium)
                Text("\(count)")
                    .font(AtlasFont.mono(10))
                    .opacity(0.55)
            }
            .foregroundStyle(tabForeground(option, active: active))
            .monospacedDigit()

            Rectangle()
                .fill(active ? tabUnderline(option) : Color.clear)
                .frame(height: 1.5)
                .shadow(color: active ? tabUnderline(option).opacity(0.35) : .clear, radius: 4, y: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    func tabForeground(_ option: AtlasCodeGraphStateFilter, active: Bool) -> Color {
        guard active else { return AtlasTheme.textTertiary }
        return option == .violating ? AtlasCodePalette.alert : AtlasTheme.textPrimary
    }

    func tabUnderline(_ option: AtlasCodeGraphStateFilter) -> Color {
        option == .violating ? AtlasCodePalette.alert : AtlasTheme.accent
    }
}
// MARK: - Worktree chrome

extension AtlasCodeView {
    // MARK: Worktrees (WAVE-087 Judgment)

    @ViewBuilder
    func worktreesSection(_ worktrees: [AtlasCodeWorktree]) -> some View {
        let face = AtlasCodeWorktreeJudgment.sectionFace(worktrees)
        if face != .silence {
            VStack(alignment: .leading, spacing: 8) {
                Text(AtlasCodeGraphJudgment.productWorktreesKicker)
                    .font(AtlasFont.mono(10))
                    .tracking(1.1)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(A11yID.codeGraphWorktrees)
                    .accessibilityLabel(AtlasCodeWorktreeJudgment.spokenSection(worktrees))
                    .accessibilityValue(face.productWord)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(AtlasCodeWorktreeJudgment.rank(worktrees)) { worktree in
                            worktreeChip(worktree)
                        }
                    }
                }
            }
        }
    }

    func worktreeChip(_ worktree: AtlasCodeWorktree) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(worktree.pathLabel)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
            HStack(spacing: 5) {
                if let branch = worktree.branch?.nonEmpty {
                    Text(branch)
                }
                if let head = worktree.head?.nonEmpty {
                    Text(String(head.prefix(8)))
                        .monospacedDigit()
                }
                if let state = worktree.state?.nonEmpty {
                    Text(state)
                }
            }
            .font(AtlasFont.mono(9))
            .foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
        .overlay(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeWorktreeJudgment.spokenChip(worktree))
    }
}
// MARK: - Week chrome

extension AtlasCodeView {
    // MARK: Week + heal receipt

    var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
                weekBody(week)
            }
            weekHealReceiptButton
        }
    }

    @ViewBuilder
    func weekBody(_ week: AtlasCodeWeek) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(AtlasCodeGraphJudgment.productTheWeek)
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                Text(week.window)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            weekMetricsOrQuiet(week)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(AtlasCodeWeekUI.spokenLabel(week))
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier(A11yID.codeWeek)
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.28),
            value: AtlasCodeWeekUI.weekPhaseID(week)
        )
    }

    @ViewBuilder
    func weekMetricsOrQuiet(_ week: AtlasCodeWeek) -> some View {
        if AtlasCodeWeekUI.isQuiet(week) {
            Text(AtlasCodeGraphJudgment.productQuietWeek)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        } else {
            HStack(spacing: 18) {
                if week.commits > 0 { weekMetric("commits", value: week.commits) }
                if week.heals > 0 { weekMetric("curas", value: week.heals) }
                if week.prevented > 0 { weekMetric("prevenidas", value: week.prevented) }
            }
            .accessibilityHidden(true)
        }
    }

    func weekMetric(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(String(value))
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .monospacedDigit()
            Text(label)
                .atlasSans(10)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    @ViewBuilder
    var weekHealReceiptButton: some View {
        if model.hasHealReceipt {
            Button { showsHealReceipt = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal")
                        .atlasSans(12)
                        .foregroundStyle(AtlasCodePalette.healed)
                        .accessibilityHidden(true)
                    Text(AtlasCodeHealVetoJudgment.spokenCuredAloneOpenReceipt)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .atlasSans(10, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(AtlasCodePalette.healed.opacity(0.07), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
                .overlay(
                    RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                        .strokeBorder(AtlasCodePalette.healed.opacity(0.3), lineWidth: 1)
                )
            }
            .accessibilityIdentifier(A11yID.codeHealReceipt)
            .accessibilityLabel(AtlasCodeHealVetoJudgment.spokenCuredAloneOpenReceipt)
            .accessibilityHint(AtlasCodeHealVetoJudgment.spokenCuredAloneOpenReceiptHint)
        }
    }
}
// MARK: - AtlasCodeGraphLane

enum AtlasCodeGraphLane {
    static let gutter: CGFloat = 72
    static let base: CGFloat = 24
    static let step: CGFloat = 36
    static let trunkWidth: CGFloat = 2.2
    static let sideWidth: CGFloat = 1.85
    static let nodeRadius: CGFloat = 5.5
    static let nodeCenterY: CGFloat = 22

    /// 0 = trunk. 1 = exceção (violating + history na MESMA faixa — sem linha cinza solta).
    static func index(for state: AtlasCodeNodeState) -> Int {
        switch state {
        case .onMain, .healed: return 0
        case .violating, .history: return 1
        }
    }

    static func x(for state: AtlasCodeNodeState) -> CGFloat {
        base + CGFloat(index(for: state)) * step
    }

    static func x(lane: Int) -> CGFloat {
        base + CGFloat(max(0, lane)) * step
    }

    static var sideX: CGFloat { x(lane: 1) }

    /// Curva GitKraken: tangentes verticais no midpoint Y.
    static func forkPath(from: CGPoint, to: CGPoint) -> Path {
        Path { path in
            let midY = (from.y + to.y) / 2
            path.move(to: from)
            path.addCurve(
                to: to,
                control1: CGPoint(x: from.x, y: midY),
                control2: CGPoint(x: to.x, y: midY)
            )
        }
    }
}
// MARK: - AtlasCodeGraphStateFilter

enum AtlasCodeGraphStateFilter: String, CaseIterable, Identifiable {
    case all
    case onMain
    case violating
    case healed
    case history

    var id: String { rawValue }

    /// Tabs do grafo AX — sem “história” (ruído; o scroll já é história).
    static let grafoTabs: [AtlasCodeGraphStateFilter] = [.all, .onMain, .violating, .healed]

    var label: String {
        switch self {
        case .all: return "todos"
        case .onMain: return "main"
        case .violating: return "fora"
        case .healed: return "curados"
        case .history: return "história"
        }
    }

    var targetState: AtlasCodeNodeState {
        switch self {
        case .onMain: return .onMain
        case .healed: return .healed
        case .violating: return .violating
        case .all, .history: return .history
        }
    }

    @MainActor
    func nodes(in nodes: [AtlasCodeGraphNode], model: AtlasCodeModel) -> [AtlasCodeGraphNode] {
        guard self != .all else { return nodes }
        let target = targetState
        return nodes.filter { model.state(for: $0) == target }
    }

    @MainActor
    func count(in nodes: [AtlasCodeGraphNode], model: AtlasCodeModel) -> Int {
        self == .all ? nodes.count : self.nodes(in: nodes, model: model).count
    }
}
