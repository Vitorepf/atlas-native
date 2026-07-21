import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Ops failure judgment+empty+copy fused

// MARK: - Judgment

// MARK: - Types

/// Exclusive shared ops-failure face (WAVE-080).
enum AtlasOpsFailureFace: Equatable {
    case network
    case domain
    case load

    var productWord: String {
        switch self {
        case .network: return "network"
        case .domain: return "domain"
        case .load: return "load"
        }
    }

    var spokenFace: String {
        switch self {
        case .network: return "falha de rede"
        case .domain: return "domínio não publicado"
        case .load: return "falha ao carregar"
        }
    }
}

// MARK: - Judgment

/// Pure ops-failure grammar — face · copy · retry · pack.
enum AtlasOpsFailureJudgment {

    static let domainHeadline = "A medição ainda não existe neste servidor"
    static let domainFootnote = "Nenhum índice, progresso ou resultado foi presumido."
    static let domainKicker = "Arena não publicada"
    static let retryLabelCentered = "Tentar de novo"
    static let retryLabelEditorial = "Tentar novamente"
    static let retrySpoken = "tentar de novo"

    static func face(mode: AtlasOpsFailureMode) -> AtlasOpsFailureFace {
        switch mode {
        case .network: return .network
        case .domainUnavailable: return .domain
        case .load: return .load
        }
    }

    static func headline(mode: AtlasOpsFailureMode) -> String {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return domainHeadline
        case .load(let headline, _):
            return headline
        }
    }

    static func footnote(mode: AtlasOpsFailureMode) -> String? {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.hint(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return domainFootnote
        case .load(_, let message):
            return message.isEmpty ? nil : message
        }
    }

    static func defaultKicker(mode: AtlasOpsFailureMode) -> String? {
        if case .domainUnavailable = mode { return domainKicker }
        return nil
    }

    static func defaultSymbol(mode: AtlasOpsFailureMode) -> String {
        switch mode {
        case .network: return "wifi.exclamationmark"
        case .domainUnavailable: return "shippingbox"
        case .load: return "exclamationmark.triangle"
        }
    }

    static func showsRetry(mode: AtlasOpsFailureMode) -> Bool {
        switch mode {
        case .network(_, let hasToken, _): return hasToken
        case .domainUnavailable, .load: return true
        }
    }

    static func spokenLabel(
        mode: AtlasOpsFailureMode,
        kicker: String?,
        spokenOverride: String?
    ) -> String {
        if let spokenOverride { return spokenOverride }
        var parts: [String] = []
        let resolvedKicker = kicker ?? defaultKicker(mode: mode)
        if let k = resolvedKicker { parts.append(k) }
        parts.append(headline(mode: mode))
        if let footnote = footnote(mode: mode) {
            parts.append(footnote.replacingOccurrences(of: "\n\n", with: ". "))
        }
        return parts.joined(separator: ". ")
    }

    static func packFacts(mode: AtlasOpsFailureMode) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(mode: mode)
        facts.append("ops_failure_face: \(face.productWord)")
        switch mode {
        case .network(_, let hasToken, let host):
            facts.append("ops_failure_host: \(host)")
            facts.append("ops_failure_has_token: \(hasToken)")
            absences.append("superfície offline ou sem token")
        case .domainUnavailable:
            absences.append("domínio não publicado — sem inventar scores")
        case .load(let headline, let message):
            facts.append("ops_failure_headline: \(headline)")
            if !message.isEmpty {
                facts.append("ops_failure_message: \(message)")
            }
            absences.append("load falhou com mensagem do host")
        }
        return (facts, absences)
    }
}

// MARK: - Empty chrome

// MARK: - Ops failure canon (WAVE-008)
// Uma máquina de layout/retry/a11y para Home · Search · Conversation · Code ·
// Arena · Autônomos. Domain-unavailable ≠ offline; fail ≠ empty idle.

/// Modo da falha ops — slots, não famílias paralelas.
enum AtlasOpsFailureMode: Equatable {
    /// Rede / token — voz via `AtlasFailureCopy`.
    case network(kind: AtlasNetworkFailureKind?, hasToken: Bool, host: String)
    /// Domínio não publicado (ex.: Arena) — proíbe inventar índices/scores.
    case domainUnavailable
    /// Load falhou com headline+message do host (Code / Autônomos).
    case load(headline: String, message: String)
}

enum AtlasOpsFailureLayout: Equatable {
    case centered
    /// Arena Premium — alinhamento leading editorial, tipografia maior.
    case leadingEditorial
}

/// Primitiva única de falha ops. Hosts só passam mode + a11y + retry.
struct AtlasOpsFailureEmpty: View {
    let mode: AtlasOpsFailureMode
    var layout: AtlasOpsFailureLayout = .centered
    var kicker: String? = nil
    var symbol: String? = nil
    var topPadding: CGFloat = 56
    var accessibilityIdentifier: String
    var retryAccessibilityIdentifier: String? = nil
    var retryHint: String = "tentar de novo"
    var spokenOverride: String? = nil
    var onRetry: (() -> Void)? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch layout {
            case .centered:
                centeredBody
            case .leadingEditorial:
                leadingBody
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(spokenLabel)
        .accessibilityValue(AtlasOpsFailureJudgment.face(mode: mode).productWord)
    }

    // MARK: - Layouts

    private var centeredBody: some View {
        VStack(spacing: 0) {
            if let resolvedKicker {
                Text(resolvedKicker.uppercased())
                    .font(AtlasFont.mono(10, .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.bottom, 12)
                    .accessibilityHidden(true)
            }
            glyph
            Spacer().frame(height: 22)
            Text(headline)
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            centeredFootnoteBlock
            if showsRetry, onRetry != nil {
                Spacer().frame(height: 28)
                retryControl
            }
        }
        .padding(.horizontal, 44)
        .padding(.top, topPadding)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var centeredFootnoteBlock: some View {
        switch mode {
        case .network(let kind, let hasToken, let host):
            Spacer().frame(height: 12)
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        case .domainUnavailable, .load:
            if let footnote {
                Spacer().frame(height: 12)
                Text(footnote)
                    .font(footnoteFont)
                    .foregroundStyle(footnoteColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            }
        }
    }

    private var leadingBody: some View {
        VStack(alignment: .leading, spacing: 18) {
            glyph
            if let resolvedKicker {
                Text(resolvedKicker)
                    .font(AtlasFont.mono(11))
                    .tracking(1.2)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Text(headline)
                .font(AtlasFont.serif(28, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            }
            if showsRetry, onRetry != nil {
                retryControl
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 22)
    }

    // MARK: - Content resolution

    /// WAVE-080: headline/footnote/spoken from AtlasOpsFailureJudgment.
    private var headline: String {
        AtlasOpsFailureJudgment.headline(mode: mode)
    }

    private var footnote: String? {
        AtlasOpsFailureJudgment.footnote(mode: mode)
    }

    private var footnoteFont: Font {
        switch mode {
        case .network: return .system(.subheadline)
        case .domainUnavailable: return AtlasFont.serifItalic(16)
        case .load: return AtlasFont.mono(11)
        }
    }

    private var footnoteColor: Color {
        switch mode {
        case .network: return AtlasTheme.textSecondary
        case .domainUnavailable: return AtlasTheme.textSecondary
        case .load: return AtlasTheme.textTertiary
        }
    }

    private var resolvedSymbol: String {
        symbol ?? AtlasOpsFailureJudgment.defaultSymbol(mode: mode)
    }

    private var resolvedKicker: String? {
        kicker ?? AtlasOpsFailureJudgment.defaultKicker(mode: mode)
    }

    private var showsRetry: Bool {
        AtlasOpsFailureJudgment.showsRetry(mode: mode)
    }

    private var spokenLabel: String {
        AtlasOpsFailureJudgment.spokenLabel(
            mode: mode,
            kicker: kicker,
            spokenOverride: spokenOverride
        )
    }

    // MARK: - Pieces

    @ViewBuilder
    private var glyph: some View {
        switch mode {
        case .network:
            Text("✦")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
        case .domainUnavailable, .load:
            Image(systemName: resolvedSymbol)
                .atlasSans(layout == .leadingEditorial ? 28 : 24)
                .foregroundStyle(layout == .leadingEditorial ? AtlasTheme.textTertiary : AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var retryControl: some View {
        if let onRetry {
            let button = Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                Text(layout == .leadingEditorial ? "Tentar novamente" : "Tentar de novo")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                    )
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel(AtlasOpsFailureJudgment.retrySpoken)
            .accessibilityHint(retryHint)

            if let retryAccessibilityIdentifier {
                button.accessibilityIdentifier(retryAccessibilityIdentifier)
            } else {
                button
            }
        }
    }
}

// MARK: - Copy

extension AtlasFailureCopy {
    static func authServerHeadline(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "A chave do Atlas foi recusada."
        case .maintenance: return "Atlas está em manutenção."
        case .serverUnavailable: return "O servidor está indisponível."
        default: return "O servidor está fora de alcance."
        }
    }
}

extension AtlasFailureCopy {
    static func authServerHint(kind: AtlasNetworkFailureKind) -> String {
        switch kind {
        case .unauthorized: return "O ATLAS_TOKEN mudou no servidor. Atualize o Secrets.xcconfig e reinstale."
        case .maintenance: return "O servidor pediu uma pausa via Retry-After. O app aguarda você tentar de novo quando a janela terminar."
        case .serverUnavailable: return "O servidor respondeu, mas está fora do ar. Veja os logs no Mac."
        default: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHint(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Sem rede no iPhone. O Atlas volta sozinho assim que a conexão voltar."
        case .timedOut: return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHint(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHint(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "No Mac, suba o servidor: o container atlas-backend parou."
        case .connectionLost: return "Instabilidade momentânea — tentar de novo costuma resolver."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func hint(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Configure o token no Mac e reinstale — nada foi perdido." }
        guard let kind else {
            return "Confira se o Mac está acordado e o Tailscale ligado — a conversa continua de onde parou."
        }
        return networkHint(kind: kind) ?? authServerHint(kind: kind)
    }
}

extension AtlasFailureCopy {
    static func networkOfflineHeadline(kind: AtlasNetworkFailureKind) -> String? {
        switch kind {
        case .offline: return "Você está sem internet."
        case .timedOut: return "O Mac não respondeu a tempo."
        default: return nil
        }
    }
}

extension AtlasFailureCopy {
    static func networkHeadline(kind: AtlasNetworkFailureKind) -> String? {
        if let offline = networkOfflineHeadline(kind: kind) { return offline }
        switch kind {
        case .connectionRefused: return "O servidor do Atlas não está de pé."
        case .connectionLost: return "A conexão caiu no meio do caminho."
        default: return nil
        }
    }
}

enum AtlasFailureCopy {
    static func headline(kind: AtlasNetworkFailureKind?, hasToken: Bool) -> String {
        guard hasToken else { return "Falta a chave do Atlas." }
        guard let kind else { return "O servidor está fora de alcance." }
        return networkHeadline(kind: kind) ?? authServerHeadline(kind: kind)
    }
}

// MARK: - TraceEvidenceJudgment

// MARK: - Types

/// Exclusive trace evidence chrome face (WAVE-068).
enum TraceEvidenceFace: Equatable {
    case loading
    case unavailable

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .unavailable: return "unavailable"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "consultando evidência"
        case .unavailable: return "evidência indisponível"
        }
    }
}

// MARK: - Judgment

/// Pure trace-evidence grammar — face · reason · spoken · pack.
enum TraceEvidenceJudgment {

    static func face(isLoading: Bool) -> TraceEvidenceFace {
        isLoading ? .loading : .unavailable
    }

    static func knownMissingRunReason(_ reason: String) -> String? {
        switch reason {
        case "no_workspace": return "sem workspace ligado a esta execução"
        case "no_run": return "nenhum run de engenharia vinculado"
        default: return nil
        }
    }

    static func knownUnavailableReason(_ reason: String) -> String? {
        if let missing = knownMissingRunReason(reason) { return missing }
        switch reason {
        case "multiple_runs": return "mais de um run — evidência indisponível"
        case "ambiguous_linked_runs": return "vínculo ambíguo entre runs"
        default: return nil
        }
    }

    /// Honesty: known codes → PT; else underscore→space; nil if empty.
    static func unavailableReason(_ reason: String?) -> String? {
        guard let reason, !reason.isEmpty else { return nil }
        return knownUnavailableReason(reason)
            ?? reason.replacingOccurrences(of: "_", with: " ")
    }

    static func spokenUnavailable(prefix: String, reason: String?) -> String {
        var parts = [prefix]
        if let reason = unavailableReason(reason) { parts.append(reason) }
        return parts.joined(separator: ", ")
    }

    static func spokenLoading(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? TraceEvidenceFace.loading.spokenFace : trimmed
    }

    static func packFacts(
        isLoading: Bool,
        reason: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(isLoading: isLoading)
        facts.append("trace_evidence_face: \(face.productWord)")
        if isLoading {
            absences.append("evidência ainda consultando")
        } else {
            absences.append("evidência indisponível neste recorte")
            if let reason, !reason.isEmpty {
                facts.append("trace_evidence_reason: \(reason)")
                if let spoken = unavailableReason(reason) {
                    facts.append("trace_evidence_reason_pt: \(spoken)")
                }
            }
        }
        return (facts, absences)
    }
}

// MARK: - Chrome

// MARK: - TraceEvidenceChrome

enum TraceEvidenceCopy {
    static func knownMissingRunReason(_ reason: String) -> String? {
        TraceEvidenceJudgment.knownMissingRunReason(reason)
    }

    static func knownUnavailableReason(_ reason: String) -> String? {
        TraceEvidenceJudgment.knownUnavailableReason(reason)
    }

    static func unavailableReason(_ reason: String?) -> String? {
        TraceEvidenceJudgment.unavailableReason(reason)
    }

    static func unavailableSpoken(prefix: String, reason: String?) -> String {
        TraceEvidenceJudgment.spokenUnavailable(prefix: prefix, reason: reason)
    }
}

struct TraceEvidenceLoading: View {
    let text: String
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 12) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(TraceEvidenceJudgment.spokenLoading(text))
        .accessibilityValue(TraceEvidenceFace.loading.productWord)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableIconTitle: some View {
        Image(systemName: systemImage)
            .font(.title2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
        Text(title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .multilineTextAlignment(.center)
            .accessibilityHidden(true)
    }
}

extension TraceEvidenceUnavailable {
    @ViewBuilder
    var unavailableSubtitle: some View {
        if let subtitle, !subtitle.isEmpty {
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
        }
    }
}

extension TraceEvidenceUnavailable {
    var unavailableStack: some View {
        VStack(spacing: 12) {
            unavailableIconTitle
            unavailableSubtitle
        }
    }
}

struct TraceEvidenceUnavailable: View {
    let title: String
    let subtitle: String?
    let identifier: String
    let spoken: String
    var systemImage: String = "doc.text"

    var body: some View {
        unavailableStack
            .padding(36)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spoken)
            .accessibilityValue(TraceEvidenceFace.unavailable.productWord)
            .accessibilityIdentifier(identifier)
    }
}
