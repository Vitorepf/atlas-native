import SwiftUI
import AtlasCore

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

    private var headline: String {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return "A medição ainda não existe neste servidor"
        case .load(let headline, _):
            return headline
        }
    }

    private var footnote: String? {
        switch mode {
        case .network(let kind, let hasToken, _):
            return AtlasFailureCopy.hint(kind: kind, hasToken: hasToken)
        case .domainUnavailable:
            return "Nenhum índice, progresso ou resultado foi presumido."
        case .load(_, let message):
            return message.isEmpty ? nil : message
        }
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
        if let symbol { return symbol }
        switch mode {
        case .network: return "wifi.exclamationmark"
        case .domainUnavailable: return "shippingbox"
        case .load: return "exclamationmark.triangle"
        }
    }

    private var resolvedKicker: String? {
        if let kicker { return kicker }
        if case .domainUnavailable = mode { return "Arena não publicada" }
        return nil
    }

    private var showsRetry: Bool {
        switch mode {
        case .network(_, let hasToken, _): return hasToken
        case .domainUnavailable, .load: return true
        }
    }

    private var spokenLabel: String {
        if let spokenOverride { return spokenOverride }
        var parts: [String] = []
        if let k = resolvedKicker { parts.append(k) }
        parts.append(headline)
        if let footnote { parts.append(footnote.replacingOccurrences(of: "\n\n", with: ". ")) }
        return parts.joined(separator: ". ")
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
            .accessibilityLabel("tentar de novo")
            .accessibilityHint(retryHint)

            if let retryAccessibilityIdentifier {
                button.accessibilityIdentifier(retryAccessibilityIdentifier)
            } else {
                button
            }
        }
    }
}
