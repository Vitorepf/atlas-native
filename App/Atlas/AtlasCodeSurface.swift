import SwiftUI
import AtlasCore

// WAVE-061: graph screen face → AtlasCodeGraphScreenJudgment

extension AtlasCodeView {
    /// WAVE-061: exclusive graph-screen face from published phase + nodes.
// MARK: - Screen face / spoken
    var graphScreenFace: AtlasCodeGraphScreenFace {
        let fail: String? = {
            if case .failed(let message) = model.phase { return message }
            return nil
        }()
        return AtlasCodeGraphScreenJudgment.face(
            phase: model.phase,
            nodeCount: model.graph?.nodes.count ?? 0,
            failMessage: fail
        )
    }

    func spokenCodeScreenLabel() -> String {
        AtlasCodeGraphScreenJudgment.spokenScreen(
            repo: model.repo,
            face: graphScreenFace
        )
    }

    static let codeScreenHint = "mapa governado; pílula e proveniência só com dados publicados"
}

extension AtlasCodeView {
    struct WhyFileTarget: Identifiable {
        let path: String
        var id: String { path }
    }

    /// As âncoras que EXISTEM nesta janela do grafo.
    ///
    /// A resposta cita commits do repositório inteiro; a tela carrega 200. Um
    /// commit de três meses atrás é âncora legítima e não está aqui. Sem cruzar
    /// os dois, a tela apagava o mapa inteiro enquanto a pílula anunciava acesos.
    /// Interseção vazia = o mapa não finge: fica inteiro.
// MARK: - Anchors / legend
    var visibleAnchors: Set<String> {
        guard askModel.isAnchoring, let nodes = model.graph?.nodes else { return [] }
        return askModel.anchors.intersection(nodes.map(\.hash))
    }

    /// O que a pílula diz sobre o mapa — contado no que ACENDEU.
    ///
    /// Três estados, três frases, nenhuma inventada:
    /// - nada ancorado → convite;
    /// - âncoras acesas → quantas, e quantas a resposta citou ao todo;
    /// - âncoras todas fora desta janela → dizer isso (mapa intacto ≠ pergunta ignorada).
    var anchorLegend: String? {
        if let focus = askFocusNode {
            return swipeFocusLegend(focus)
        }
        guard askModel.isAnchoring else { return nil }
        let acesas = visibleAnchors.count
        let citadas = askModel.anchors.count
        if acesas < citadas {
            return anchorLegendPartial(acesas: acesas, citadas: citadas)
        }
        return askModel.anchorNote
    }

    func anchorLegendPartial(acesas: Int, citadas: Int) -> String {
        if acesas == 0 {
            return citadas == 1
                ? "o commit da resposta está fora desta janela"
                : "os \(citadas) commits da resposta estão fora desta janela"
        }
        return "\(acesas) de \(citadas) acesos aqui — o resto está fora desta janela"
    }
}

extension AtlasCodeView {
    /// Swipe ou “perguntar” na proveniência: refina a pílula, NÃO abre modal.
// MARK: - Ask focus actions
    func anchorAskOnCommit(_ node: AtlasCodeGraphNode) {
        selectedNode = nil
        askFocusNode = node
        let legend = swipeFocusLegend(node)
        askModel.setSheetFocusLegend(legend)
        askDraft = "o que o commit \(citedCommitPrefix(node)) fez, e por quê?"
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
    }

    /// Compat: CTA da folha de proveniência = mesma âncora (sem sheet de ask).
    func openAskFromProvenance(_ node: AtlasCodeGraphNode) {
        anchorAskOnCommit(node)
    }

    func clearAskFocus() {
        askFocusNode = nil
        askDraft = ""
        askModel.setSheetFocusLegend(nil)
    }

    var pillIsAnchoring: Bool {
        askFocusNode != nil || askModel.isAnchoring
    }

    func citedCommitPrefix(_ node: AtlasCodeGraphNode) -> String {
        var citado = String(node.hash.prefix(10))
        var tamanho = 10
        while !citado.contains(where: \.isNumber), tamanho < node.hash.count {
            tamanho += 4
            citado = String(node.hash.prefix(tamanho))
        }
        return citado
    }

    func swipeFocusLegend(_ node: AtlasCodeGraphNode) -> String {
        let hash = citedCommitPrefix(node)
        guard let message = node.message?.trimmingCharacters(in: .whitespacesAndNewlines),
              !message.isEmpty else {
            return "referência · \(hash)"
        }
        let subject = AtlasConventionalCommit.split(message).subject
        let short = subject.count > 28 ? String(subject.prefix(27)) + "…" : subject
        return "\(hash) · \(short)"
    }
}

extension AtlasCodeView {
    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
// MARK: - Ask pill chrome
    var askPill: some View {
        askPillA11yTraits(
            askPillPaddingAnimation(
                askPillTapGesture(askPillContent)
            )
        )
    }

    @ViewBuilder
    var askPillContent: some View {
        // WAVE-016: AgenticPillFace + trailing clear/chevron (âncora WAVE-001).
        AgenticPillFace(invite: anchorLegend ?? AtlasCodeAskContext.invite) {
            askPillClearButton
            Image(systemName: "chevron.up")
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .accessibilityIdentifier(A11yID.codeAskAnchorNote)
        .contentShape(Capsule())
    }

    @ViewBuilder
    var askPillClearButton: some View {
        if askFocusNode != nil {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                clearAskFocus()
            } label: {
                Text("limpar")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AtlasCodeAskPillJudgment.clearCommitRefLabel)
            .accessibilityHint("Remove o commit da pílula")
            .accessibilityIdentifier(A11yID.codeAskClear)
        } else if askModel.isAnchoring {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                askModel.clear()
            } label: {
                Text("mostrar tudo")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(AtlasCodeAskPillJudgment.clearLabel)
            .accessibilityHint(AtlasCodeAskPillJudgment.clearHint)
            .accessibilityIdentifier(A11yID.codeAskClear)
        }
    }

    func askPillTapGesture<V: View>(_ content: V) -> some View {
        content.onTapGesture {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            // Com âncora de swipe, o draft já está semeado — não apagar.
            // Sem swipe: emptyPrompt volta ao convite genérico (limpa legenda residual).
            if askFocusNode == nil {
                askDraft = ""
                askModel.setSheetFocusLegend(nil)
            } else {
                askModel.setSheetFocusLegend(anchorLegend)
            }
            showsAskCard = true
        }
    }

    func askPillPaddingAnimation<V: View>(_ content: V) -> some View {
        content
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.22),
                value: AtlasCodeAskPillJudgment.phaseID(
                    isAnchoring: pillIsAnchoring,
                    anchorLegend: anchorLegend
                )
            )
    }

    func askPillA11yTraits<Content: View>(_ content: Content) -> some View {
        let face = AtlasCodeAskPillJudgment.face(
            isAnchoring: pillIsAnchoring,
            anchorLegend: anchorLegend
        )
        return content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                AtlasCodeAskPillJudgment.spokenPill(
                    isAnchoring: pillIsAnchoring,
                    anchorLegend: anchorLegend
                )
            )
            .accessibilityValue(face.productWord)
            .accessibilityHint(AtlasCodeAskPillJudgment.pillHint)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier(A11yID.codeAskPill)
    }
}

