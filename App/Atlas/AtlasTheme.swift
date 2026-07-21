import Foundation
import SwiftUI
import UIKit

// Cycle 044 fuse → AtlasTheme.swift

// Design system CANÔNICO do Atlas (dark) — slate teal warm + atlas gold.
enum AtlasTheme {}

private struct AtlasCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let fillOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(AtlasTheme.surface.opacity(fillOpacity)))
            // Soft gold-quiet card chrome — shared plane for atlasCard surfaces.
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(AtlasTheme.goldBorder.opacity(0.85), lineWidth: 1))
    }
}

extension View {
    /// Chrome canônico de card: surface + gold-quiet rim + cantos 14.
    func atlasCard(cornerRadius: CGFloat = AtlasTheme.Radius.card, fillOpacity: Double = 1) -> some View {
        modifier(AtlasCardModifier(cornerRadius: cornerRadius, fillOpacity: fillOpacity))
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension AtlasTheme {
    // Cores de domínio com uso real na casca
    static let domOperacional = Color(hex: 0x9B7A3F) // bronze
    static let domAutonomos = Color(hex: 0x6FA06A)   // verde (moss clareado p/ dark)

    enum Space {
        static let screen: CGFloat = 20
        /// Ritmo vertical das rows da home — um pouco mais compacto que o body
        /// padrão, sem apertar o alvo de toque.
        static let row: CGFloat = 13
    }
}

extension AtlasTheme {
    static let textPrimary = Color(hex: 0xD6DDE2)
    static let textSecondary = Color(hex: 0x95A3AC)
    static let textTertiary = Color(hex: 0x677482)
    static let accent = Color(hex: 0xD4A85A)
    static let goldVeil = Color(hex: 0xD4A85A, alpha: 0.10)
    static let goldBorder = Color(hex: 0xD4A85A, alpha: 0.34)
    // Gold-quiet ink ladder (foregroundStyle accent.opacity):
    //   0.32–0.38 ghost/disabled · 0.42 disclosure · 0.55 inactive chrome
    //   0.62 meta captions · 0.72 secondary titles · 0.88–0.92 active chrome
    // GoldBorder rim ladder: 0.4 idle · 0.45 mid · 0.55 active-soft · 1 full
    static let prussian = Color(hex: 0x7FA7C4)
    static let alert = Color(hex: 0xE08C8C)
}

extension AtlasTheme {
    static let bg = Color(hex: 0x1D2B34)
    static let bgRecessed = Color(hex: 0x15212A)
    static let surface = Color(hex: 0x243743)
    static let surfaceHi = Color(hex: 0x2D4351)
    static let separator = Color(hex: 0x313F47)
    static let separatorSoft = Color(hex: 0x27353E)
}

//
// Três raios e só três: card (superfícies/cartões), control (controles,
// recibos, blocos internos), soft (chrome menor: banners, scrubber).
// Valor fora da lei é escolha deliberada e leva comentário no local
// (ex.: composer 26 = cápsula da pílula de escrita).

extension AtlasTheme {
    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 12
        static let soft: CGFloat = 10
    }
}


// Liquid Glass circular/capsule chrome (iOS 26+) com fallback quieto.
struct AtlasGlassCircle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Circle())
        } else {
            content.background(
                Circle().fill(AtlasTheme.surface)
                    // Soft gold-quiet glass fallback — match capsule + composer disks.
                    .overlay(Circle().stroke(AtlasTheme.goldBorder.opacity(0.55), lineWidth: 1)))
        }
    }
}

struct AtlasGlassCapsule: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            content.background(
                Capsule().fill(AtlasTheme.bgRecessed.opacity(0.82))
                    // Soft gold-quiet glass fallback — match Liquid Glass gold rim family.
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder.opacity(0.55), lineWidth: 1)))
        }
    }
}

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
    func atlasGlassCapsule() -> some View { modifier(AtlasGlassCapsule()) }

    /// Skip empty/nil identifiers so XCUITest never sees `""` nodes.
    @ViewBuilder
    func atlasAccessibilityIdentifier(_ id: String?) -> some View {
        if let id, !id.isEmpty {
            self.accessibilityIdentifier(id)
        } else {
            self
        }
    }

    /// Skip empty/nil hints — VoiceOver ignores absence better than blank strings.
    @ViewBuilder
    func atlasAccessibilityHint(_ hint: String?) -> some View {
        if let hint, !hint.isEmpty {
            self.accessibilityHint(hint)
        } else {
            self
        }
    }

    /// Soft elevation shadow — shared depth for glass pills and elevated chrome.
    /// Default opacity 0.16 keeps gold-quiet chrome lifted without heavy slate drop.
    func atlasElevation(radius: CGFloat = 10, y: CGFloat = 4, opacity: Double = 0.16) -> some View {
        shadow(color: .black.opacity(opacity), radius: radius, y: y)
    }
}

/// Pure gold-breath 1pt hairline — sectionLabel / radar / sheet divider family (0.28 / 0.12).
/// Funde gradients duplicados nas views; padding/inset fica no call site.
struct AtlasGoldBreathHairline: View {
    enum Peak {
        /// 0 → 0.28 → 0.12 → 0
        case single
        /// 0 → 0.28 → 0.12 → 0.28 → 0 (Autônomos / Arena mid)
        case double
        /// 0 → 0.28 → 0.12 (braço esquerdo do sectionLabel)
        case fadeIn
        /// 0.12 → 0.28 → 0 (braço direito do sectionLabel)
        case fadeOut
    }

    var peak: Peak = .single

    var body: some View {
        LinearGradient(
            colors: colors.map { AtlasTheme.accent.opacity($0) },
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .accessibilityHidden(true)
    }

    private var colors: [Double] {
        switch peak {
        case .single: return [0, 0.28, 0.12, 0]
        case .double: return [0, 0.28, 0.12, 0.28, 0]
        case .fadeIn: return [0, 0.28, 0.12]
        case .fadeOut: return [0.12, 0.28, 0]
        }
    }
}

/// Soft gold-tinted sheet/keyboard grabber — quiet luxury, not pure slate bar.
struct AtlasGoldGrabber: View {
    var width: CGFloat = 42
    var height: CGFloat = 5
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AtlasTheme.accent.opacity(0.34))
            .frame(width: width, height: height)
            .accessibilityHidden(true)
    }
}

/// Short gold title underline — masthead / screen principal family (not full hairline).
struct AtlasGoldTitleRule: View {
    var width: CGFloat = 44
    var height: CGFloat = 1.5
    /// Peak opacity at center (home masthead uses ~0.82; screen titles ~0.5).
    var peak: Double = 0.5
    var body: some View {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0),
                AtlasTheme.accent.opacity(peak),
                AtlasTheme.accent.opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: width, height: height)
        .accessibilityHidden(true)
    }
}

/// Diagonal gold stroke gradient for AgenticPill / floating invite glass rims.
enum AtlasGoldChrome {
    static var pillStroke: LinearGradient {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0.32),
                AtlasTheme.accent.opacity(0.06),
                AtlasTheme.accent.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Soft horizontal gold stroke for empty-suggestion capsules.
    static var suggestionStroke: LinearGradient {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0.28),
                AtlasTheme.accent.opacity(0.08),
                AtlasTheme.accent.opacity(0.18)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Soft 1pt rule between dense editorial blocks (markdown tables/lists).
    static var softRule: some View {
        Rectangle()
            .fill(AtlasTheme.accent.opacity(0.14))
            .frame(height: 1)
            .accessibilityHidden(true)
    }

    /// Stronger 1pt rule for state markers (new-since-visit).
    static var stateRule: some View {
        Rectangle()
            .fill(AtlasTheme.accent.opacity(0.48))
            .frame(height: 1)
            .accessibilityHidden(true)
    }

    /// Fade under floating AgenticPill dock (Autônomos / Arena).
    static var askDockFade: some View {
        LinearGradient(
            colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 28)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Full-screen bg veil for composer/workspace shells.
    static var screenBgVeil: some View {
        LinearGradient(
            colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}





// Cycle 044 fuse → AtlasMotion.swift

// Fundação de motion do Atlas — porte dos tokens editoriais (tokens.ts). Ritmo
// calmo, nunca overshoot Material: curva editorial + springs damping ≥0.8.
enum AtlasMotion {
    static let instinct: Double = 0.18
    static let considered: Double = 0.32
    /// Longer editorial fades (scan phase, large surface morph).
    static let ceremonial: Double = 0.48

    /// Curva editorial (ease-out suave) — a transição padrão.
    static let editorial = Animation.timingCurve(0.22, 1, 0.36, 1, duration: considered)
    /// Chegada da resposta (pousa como papel).
    static let arrival = Animation.spring(response: 0.42, dampingFraction: 0.82)
    /// Respiração de streaming / breath do send.
    static func breath(_ duration: Double = 0.9) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}

extension AtlasMotion {
    /// Haptics are UI-only; isolate on MainActor for StrictConcurrency.
    @MainActor
    static func softImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    @MainActor
    static func mediumImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

extension AtlasMotion {
    @MainActor
    static func successNotification(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Numeric text morph só quando Reduce Motion está desligado.
struct NumericTextTransition: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.contentTransition(.numericText())
        } else {
            content
        }
    }
}

@MainActor
enum AtlasMotionPresentation {
    /// Transição editorial condicional — nil com Reduce Motion.
    static func editorial(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : AtlasMotion.editorial
    }
}

// Botão com press-scale spring (tato físico). Reduce Motion = sem scale nem bounce.
struct PressableScale: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Soft press — 0.975 scale + 0.94 opacity keeps gold chrome readable under finger.
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.975 : 1))
            .opacity(reduceMotion ? 1 : (configuration.isPressed ? 0.94 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        // Editorial: damping ≥0.8 — never Material overshoot.
                        : .spring(response: 0.28, dampingFraction: 0.84)),
                value: configuration.isPressed
            )
    }
}


// Cycle 044 fuse → BreathingDiamond.swift

// Losango bronze respirando (SyncDiamond) — indicador decorativo de execução viva.
// Sempre silenciado no VoiceOver; o spoken composto vive no container pai.
struct BreathingDiamond: View {
    let size: CGFloat
    /// Quando nil, lê `@Environment(\.accessibilityReduceMotion)`.
    var reduceMotion: Bool? = nil

    @Environment(\.accessibilityReduceMotion) var envReduceMotion
    @State var on = false

    var effectiveReduceMotion: Bool { reduceMotion ?? envReduceMotion }

    var body: some View {
        applyBreathHandlers(breathingDiamondShape)
    }
}

extension BreathingDiamond {
    var breathingDiamondShape: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AtlasTheme.accent)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .shadow(color: AtlasTheme.accent.opacity(on ? 0.55 : 0.25), radius: on ? 7 : 3, y: 0)
            .scaleEffect(on ? 1.2 : 1)
            .opacity(on ? 0.5 : 1)
            .accessibilityHidden(true)
    }
}

extension BreathingDiamond {
    func applyBreathHandlers<Content: View>(_ content: Content) -> some View {
        content
            .onAppear {
                if effectiveReduceMotion {
                    on = false
                } else {
                    withAnimation(AtlasMotion.breath(0.9)) { on = true }
                }
            }
            .onChange(of: effectiveReduceMotion) { _, paused in
                if paused {
                    on = false
                } else if !on {
                    withAnimation(AtlasMotion.breath(0.9)) { on = true }
                }
            }
    }
}


// Cycle 044 fuse → AtlasType.swift

// Tipografia do Atlas: Fraunces (serif editorial) pro masthead e títulos — a
// identidade do app original — com SF Pro no corpo/listas (clareza estilo Cursor).
//
// DYNAMIC TYPE: todo Font.custom sai com `relativeTo:` — a tipografia inteira
// escala com o ajuste de texto do operador (acessibilidade não é opcional).
enum AtlasFont {
    /// Serif Fraunces. Só SemiBold é usado na casca (28/28); Regular é o
    /// fallback do default — Bold/Medium foram podados (0 chamadas).
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        let name: String
        switch weight {
        case .semibold: name = "Fraunces-SemiBold"
        default: name = "Fraunces-Regular"
        }
        return .custom(name, size: size, relativeTo: anchor(size))
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("Fraunces-Italic", size: size, relativeTo: anchor(size))
    }

    /// JetBrains Mono (código) — o mono do Atlas.
    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom(weight == .medium ? "JetBrainsMono-Medium" : "JetBrainsMono-Regular",
                size: size, relativeTo: anchor(size))
    }
}

extension AtlasFont {
    static func anchorLarge(_ size: CGFloat) -> Font.TextStyle? {
        switch size {
        case 28...: return .largeTitle
        case 22..<28: return .title2
        case 17..<22: return .body
        default: return nil
        }
    }
}

extension AtlasFont {
    static func anchorSmall(_ size: CGFloat) -> Font.TextStyle {
        switch size {
        case 14..<17: return .callout
        case 12..<14: return .footnote
        default: return .caption2
        }
    }
}

extension AtlasFont {
    static func anchor(_ size: CGFloat) -> Font.TextStyle {
        anchorLarge(size) ?? anchorSmall(size)
    }
}

//
// `.font(.system(size:))` é FIXO: ignora o ajuste de texto do operador.
// `.atlasSans(size, weight)` ancora o tamanho na mesma régua do serif/mono
// (anchor) e escala via UIFontMetrics com a categoria lida do environment —
// na régua padrão o resultado é pixel-idêntico ao que era.

extension View {
    func atlasSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> some View {
        modifier(AtlasSansFont(size: size, weight: weight))
    }
}

struct AtlasSansFont: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let size: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(AtlasFont.sans(size, weight: weight, at: typeSize))
    }
}

extension AtlasFont {
    /// SF escalado por categoria explícita (o modifier entrega a do environment).
    /// Lookup puro na curva pré-computada — zero UIKit em body.
    @MainActor
    static func sans(_ size: CGFloat, weight: Font.Weight, at typeSize: DynamicTypeSize) -> Font {
        .system(size: size * AtlasSansScale.factor(uiTextStyle(anchor(size)), typeSize),
                weight: weight)
    }
}

extension AtlasFont {
    static func uiTextStyle(_ style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default: return .body
        }
    }

    static func contentCategory(_ typeSize: DynamicTypeSize) -> UIContentSizeCategory {
        switch typeSize {
        case .xSmall: return .extraSmall
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .xLarge: return .extraLarge
        case .xxLarge: return .extraExtraLarge
        case .xxxLarge: return .extraExtraExtraLarge
        case .accessibility1: return .accessibilityMedium
        case .accessibility2: return .accessibilityLarge
        case .accessibility3: return .accessibilityExtraLarge
        case .accessibility4: return .accessibilityExtraExtraLarge
        case .accessibility5: return .accessibilityExtraExtraExtraLarge
        @unknown default: return .large
        }
    }
}

//
// UIFontMetrics/UIFont em body corrompia heap: o engine de acessibilidade
// avalia bodies fora da main e UIKit não é thread-safe (SIGSEGV com sítio
// aleatório na bateria XCUITest). A curva oficial da Apple é lida UMA vez,
// na main, no launch (AtlasApp força `prime()`); depois o sans é lookup puro.

@MainActor
enum AtlasSansScale {
    private static var table: [UIFont.TextStyle: [DynamicTypeSize: CGFloat]] = [:]

    /// Chamar no launch (main). Idempotente.
    static func prime() {
        guard table.isEmpty else { return }
        let styles: [UIFont.TextStyle] = [
            .largeTitle, .title1, .title2, .title3, .headline, .subheadline,
            .body, .callout, .footnote, .caption1, .caption2,
        ]
        for style in styles {
            let metrics = UIFontMetrics(forTextStyle: style)
            var row: [DynamicTypeSize: CGFloat] = [:]
            for typeSize in DynamicTypeSize.allCases {
                let traits = UITraitCollection(
                    preferredContentSizeCategory: AtlasFont.contentCategory(typeSize))
                row[typeSize] = metrics.scaledValue(for: 100, compatibleWith: traits) / 100
            }
            table[style] = row
        }
    }

    static func factor(_ style: UIFont.TextStyle, _ typeSize: DynamicTypeSize) -> CGFloat {
        prime()
        return table[style]?[typeSize] ?? 1
    }
}


// Cycle 044 fuse → A11yID.swift

/// Identifiers de acessibilidade canônicos — um único vocabulário entre a
/// casca e os XCUITests. Home/Search: +Home · Autônomos: +Autonomos ·
/// Code/radar: +Code · Arena/review: +Surfaces · Queue/Live: +QueueLive ·
/// Execution/plan: +Execution.
enum A11yID {
    static let topbarCode = "topbar-code"
    static let auditMasthead = "audit-masthead"
    static let conversationScreen = "conversation-screen"
    static let conversationEmpty = "conversation-empty"
    static let conversationInput = "conversation-input"
    static let conversationSend = "conversation-send"
    static let conversationOptions = "conversation-options"
    static let conversationToast = "conversation-toast"
    static let conversationOutline = "conversation-outline"
    static let conversationOutlineSheet = "conversation-outline-sheet"
    static let conversationOutlineEmpty = "conversation-outline-empty"
    static let conversationStaleReadSeal = "conversation-stale-read-seal"
    static let conversationHeaderContinuity = "conversation-header-continuity"
    static let composerAttachmentStrip = "composer-attachment-strip"
    static let conversationNewMarker = "conversation-new-marker"
    static let conversationOutlineRowPrefix = "conversation-outline-row-"
    static let conversationLoadFailure = "conversation-load-failure"
    static let conversationScrollFAB = "conversation-scroll-fab"
    static let continuityHandoffReceipt = "continuity-handoff-receipt"
}

extension A11yID {
    static let arenaPremiumAdd = "arena-premium-add"
    static let arenaPremiumStop = "arena-premium-stop"
    static let arenaPremiumStopConfirm = "arena-premium-stop-confirm"
    static let arenaPremiumExecution = "arena-premium-execution"
    static let arenaPremiumExecutionPipeline = "arena-premium-execution-pipeline"
    static let arenaPremiumRunDetail = "arena-premium-run-detail"
    static let arenaPremiumRunDetailCases = "arena-premium-run-detail-cases"
    static let arenaPremiumPlan = "arena-premium-plan"
    static let arenaPremiumQueue = "arena-premium-queue"
    static let arenaPremiumAlerts = "arena-premium-alerts"
    static let arenaPremiumResults = "arena-premium-results"
    static let arenaPremiumFleet = "arena-premium-fleet"
    static let arenaPremiumCapabilities = "arena-premium-capabilities"
    static let arenaPremiumEnginePicker = "arena-premium-engine-picker"
    static let arenaPremiumAskPill = "arena-premium-ask-pill"

    static func arenaPremiumFleetRow(_ engine: String) -> String {
        "arena-premium-fleet-row-\(engine)"
    }
    static let arenaPremiumCapabilityDetail = "arena-premium-capability-detail"
    static let arenaPremiumExecutionAction = "arena-premium-execution-action"
    static let arenaPremiumAlertsAction = "arena-premium-alerts-action"
    static let arenaPremiumStopSheet = "arena-premium-stop-sheet"
    static let arenaPremiumStopActor = "arena-premium-stop-actor"
    static let arenaPremiumStopReason = "arena-premium-stop-reason"
    static let arenaPremiumStopReceipt = "arena-premium-stop-receipt"

    static func arenaPremiumTab(_ name: String) -> String {
        "arena-premium-tab-\(name)"
    }

    static func arenaPremiumState(_ phase: String) -> String {
        "arena-premium-state-\(phase)"
    }

    static func arenaPremiumPlanRow(_ suite: String) -> String {
        "arena-premium-plan-row-\(suite)"
    }

    static func arenaPremiumQueueRow(_ suite: String) -> String {
        "arena-premium-queue-row-\(suite)"
    }

    static func arenaPremiumExecutionRun(_ run: String) -> String {
        "arena-premium-execution-run-\(run)"
    }

    static func arenaPremiumResultSuite(_ suite: String) -> String {
        "arena-premium-result-suite-\(suite)"
    }
}

extension A11yID {
    static let autonomosScreen = "autonomos-screen"
    static let autonomosRhythmLine = "autonomos-rhythm-line"
    static let autonomosRhythmSheet = "autonomos-rhythm-sheet"
    static let autonomosRhythmUnmute = "autonomos-rhythm-unmute"
    static let autonomosHub = "autonomos-hub"
    static let autonomosList = "autonomos-list"
    static let autonomosListEmpty = "autonomos-list-empty"
    static func autonomosUnit(_ id: String) -> String { "autonomos-unit-\(id)" }
    static func autonomosNav(_ title: String) -> String {
        "autonomos-nav-\(title.lowercased().replacingOccurrences(of: " ", with: "-"))"
    }
    static let autonomosNew = "autonomos-new"
    static let autonomosNewName = "autonomos-new-name"
    static let autonomosNewCharter = "autonomos-new-charter"
    static let autonomosEvolution = "autonomos-evolution"
    static let autonomosAskPill = "autonomos-ask-pill"
    static let autonomosSelfConstructionBanner = "autonomos-self-construction-banner"
    static let autonomosMissingUnit = "autonomos-missing-unit"
    static let autonomosReasonSheet = "autonomos-reason-sheet"
    static let autonomosReasonActor = "autonomos-reason-actor"
    static let autonomosReasonField = "autonomos-reason-field"
    static let autonomosReasonSubmit = "autonomos-reason-submit"
}

extension A11yID {
    // M61 · Arena
    static let arenaHomeEntry = "arena-home-entry"
}

extension A11yID {
    static let arenaCapabilityRowPrefix = "arena-capability-row-"
    static func arenaCapabilityRow(_ capability: String) -> String { arenaCapabilityRowPrefix + capability }
}

extension A11yID {
    static let arenaRunSheet = "arena-run-sheet"
    static let arenaRunActor = "arena-run-actor"
    static let arenaRunReason = "arena-run-reason"
    static let arenaRunSubmit = "arena-run-submit"
    static let arenaRunReceipt = "arena-run-receipt"
    static let arenaRunEnginesEmpty = "arena-run-engines-empty"
    static let arenaRunSuitesEmpty = "arena-run-suites-empty"
    static func arenaRunEngine(_ engine: String) -> String { "arena-run-engine-\(engine)" }
    static func arenaRunArm(_ raw: String) -> String { "arena-run-arm-\(raw)" }
    static func arenaRunSuite(_ suite: String) -> String { "arena-run-suite-\(suite)" }
}

extension A11yID {
    static let arenaSuiteSheet = "arena-suite-sheet"
}

extension A11yID {
    static let artifactsRow = "artifacts-row"
    static let artifactsSheet = "artifacts-sheet"
    static let artifactsEmpty = "artifacts-empty"
    static let artifactsUnavailable = "artifacts-unavailable"
    static let artifactsLoadFailure = "artifacts-load-failure"
    static let artifactsMount = "artifacts-mount"
    static let artifactsMountCheckPrefix = "artifacts-mount-check-"
    static func artifactsMountCheck(_ index: Int) -> String { artifactsMountCheckPrefix + String(index) }
    static let artifactsItemPrefix = "artifacts-item-"
    static func artifactsItem(_ index: Int) -> String { artifactsItemPrefix + String(index) }
    static let artifactsZoomImage = "artifacts-zoom-image"
}

extension A11yID {
    static let autonomosHeader = "autonomos-header"
    static let autonomosBack = "autonomos-back"
    static let autonomosRefresh = "autonomos-refresh"
    static let autonomosControlError = "autonomos-control-error"
    static let autonomosLoadFailure = "autonomos-load-failure"
    static let autonomosRetry = "autonomos-retry"
}

extension A11yID {
    static let codeStatus = "code-status"
    static let codeRepoSwitcher = "code-repo-switcher"
    static let codeRepoPicker = "code-repo-picker"
    static let codeRepoPickerRowPrefix = "code-repo-picker-row-"
    static let codeGraphTruncated = "code-graph-truncated"
    static let codeGraphFilters = "code-graph-filters"
    static let codeGraphWorktrees = "code-graph-worktrees"
    static let codeGraphFilterPrefix = "code-graph-filter-"
}

extension A11yID {
    static func codeCommit(hashPrefix: String) -> String { codeCommitPrefix + hashPrefix }
    static func codeGraphFilter(_ raw: String) -> String { codeGraphFilterPrefix + raw }
}

extension A11yID {
    static let codeHealReceipt = "code-heal-receipt"
    static let codeHealReceiptSheet = "code-heal-receipt-sheet"
    static let codeHealStepPrefix = "code-heal-step-"
    static let codeHealUndoWindow = "code-heal-undo-window"
    static let codeHealUndo = "code-heal-undo"
}

extension A11yID {
    static func codeHealStep(_ index: Int) -> String { codeHealStepPrefix + String(index) }
    static func whyRow(_ index: Int) -> String { whyRowPrefix + String(index) }
    static func whyFileRow(_ index: Int) -> String { whyFileRowPrefix + String(index) }
}

extension A11yID {
    static func codeRepoPickerRow(_ slug: String) -> String {
        codeRepoPickerRowPrefix + slug
    }
}

extension A11yID {
    static let codeAskAnchorNote = "code-ask-anchor-note"
    static let codeAskClear = "code-ask-clear"
    static let codeAskPill = "code-ask-pill"
    static let codeProvenanceLaw = "code-provenance-law"
    static let codeProvenanceAsk = "code-provenance-ask"
    static let codeProvenanceState = "code-provenance-state"
    static let codeCommitBody = "code-commit-body"
    static let codeCommitFiles = "code-commit-files"
    static let whySheet = "why-sheet"
    static let whyRowPrefix = "why-row-"
    static let whyFileRowPrefix = "why-file-row-"
    static let codeMirror = "code-mirror"
    static let codeWeek = "code-week"
}

extension A11yID {
    static let radarScreen = "code-radar"
    static let codeScreen = "code-screen"
    static let radarLoading = "code-radar-loading"
    static let radarFailure = "code-radar-failure"
    static let radarEmpty = "code-radar-empty"
    static let codeLoadFailure = "code-load-failure"
    static let codeLoadRetry = "code-load-retry"
    static let radarStatus = "radar-status"
    static let radarRecents = "radar-recents"
    static let radarFolders = "radar-folders"
    static let radarLoose = "radar-loose"
    static let radarRepoPrefix = "radar-repo-"
    static let radarFolderPrefix = "radar-folder-"
    static let codeCommitPrefix = "code-commit-"
}

extension A11yID {
    static func radarRepo(_ slug: String) -> String { radarRepoPrefix + slug }
    static func radarFolder(_ slug: String) -> String { radarFolderPrefix + slug }
}

extension A11yID {
    static let cameraPicker = "composer-camera-picker"
    static let attachmentsSheet = "composer-attachments-sheet"
    static let attachmentPhoto = "composer-attachment-photo"
    static let attachmentFile = "composer-attachment-file"
    static let attachmentPaste = "composer-attachment-paste"
}

extension A11yID {
    static let draftPrefix = "composer-draft-"
    static let draftRemovePrefix = "composer-draft-remove-"
    static func draft(_ id: String) -> String { draftPrefix + id }
    static func draftRemove(_ id: String) -> String { draftRemovePrefix + id }
}

extension A11yID {
    static let modeSheet = "composer-mode-sheet"
    static let effortSheet = "composer-effort-sheet"
    static let modeRowPrefix = "composer-mode-row-"
    static let effortRowPrefix = "composer-effort-row-"
    static func modeRow(_ key: String) -> String { modeRowPrefix + key }
    static func effortRow(_ effort: String) -> String { effortRowPrefix + effort }
}

extension A11yID {
    // M07 · Steering
    static let steerSheet = "steer-sheet"
    static let steerInstruction = "steer-instruction"
    static let steerScope = "steer-scope"
    static let steerSubmit = "steer-submit"
    static let steerReceipt = "steer-receipt"
}

extension A11yID {
    static let workspaceSheet = "composer-workspace-sheet"
    static let workspaceRowPrefix = "composer-workspace-row-"
    static func workspaceRow(_ key: String) -> String { workspaceRowPrefix + key }
}

extension A11yID {
    static func conversationOutlineRow(_ index: Int) -> String { conversationOutlineRowPrefix + String(index) }
}

extension A11yID {
    static let editorialTurnSignature = "editorial-turn-signature"
    static let editorialTurnFeedbackPrefix = "editorial-turn-feedback-"
    static func editorialTurnFeedback(_ kind: String) -> String { editorialTurnFeedbackPrefix + kind }
}

extension A11yID {
    static let executionReconnectBanner = "execution-reconnect-banner"
    static let executionSilenceWatchdog = "execution-silence-watchdog"
    static let executionReplayScrubber = "execution-replay-scrubber"
    static let executionProof = "execution-proof"
    static let executionStateCard = "execution-state-card"
    static let executionRetry = "execution-retry"
    static let executionActionChoicePrefix = "execution-action-"
    static func executionActionChoice(_ id: String) -> String { executionActionChoicePrefix + id }
}

extension A11yID {
    static let topbarSearch = "topbar-search"
    static let topbarProfile = "topbar-profile"
    static let profileSheet = "profile-sheet"
    static let profileAuditToggle = "profile-audit-toggle"
    static let homeAddWorkspace = "home-add-workspace"
    static let workspacePickerSheet = "workspace-picker-sheet"
    static let workspacePickerRowPrefix = "workspace-picker-"
    static func workspacePickerRow(_ slug: String) -> String { workspacePickerRowPrefix + slug }
    static let workspacePickerNoRepo = "workspace-picker-no-repo"
    static let homeInputPill = "home-input-pill"
    static let homeLoading = "home-loading"
    static let homeOffline = "home-offline"
    static let homeRetry = "home-retry"
}

extension A11yID {
    static let homeConversasSection = "home-conversas-section"
    static let homeOperacaoSection = "home-operacao-section"
    static let homeWorkspacesSection = "home-workspaces-section"
    static let homeConversasEntry = "home-conversas-entry"
    static let homeAutonomosEntry = "home-autonomos-entry"
}

extension A11yID {
    static let homeWorkspacePrefix = "home-workspace-"
    static func homeWorkspace(_ key: String) -> String { homeWorkspacePrefix + key }
}

extension A11yID {
    static let liveNowSection = "live-now-section"
    static let liveNowRowPrefix = "live-now-row-"
    static let liveNowRemoteBadgePrefix = "live-now-remote-badge-"
    static func liveNowRow(_ index: Int) -> String { liveNowRowPrefix + String(index) }
    static func liveNowRemoteBadge(_ index: Int) -> String { liveNowRemoteBadgePrefix + String(index) }
}

extension A11yID {
    static let liveTimeline = "live-timeline"
    static let liveTimelineFilters = "live-timeline-filters"
    static let liveTimelineFilterSilence = "live-timeline-filter-silence"
    static let liveTimelineFilterPrefix = "live-timeline-filter-"
    static func liveTimelineFilter(_ raw: String) -> String { liveTimelineFilterPrefix + raw }
}

extension A11yID {
    static let markdownCodeBlockPrefix = "markdown-code-block-"
    static let markdownCodeCopyPrefix = "markdown-code-copy-"
    static func markdownCodeBlock(_ index: Int) -> String { markdownCodeBlockPrefix + String(index) }
    static func markdownCodeCopy(_ index: Int) -> String { markdownCodeCopyPrefix + String(index) }
}

extension A11yID {
    static let nightlyProposalCard = "nightly-proposal-card"
    static let nightlyProposalAccept = "nightly-proposal-accept"
    static let nightlyProposalDismiss = "nightly-proposal-dismiss"
    static let nightlyProposalMute = "nightly-proposal-mute"

    static let selfReceiptSheet = "self-receipt-sheet"
    static let selfReceiptVeto = "self-receipt-veto"
}

extension A11yID {
    static let planCard = "plan-card"
    static let planDetailToggle = "plan-detail-toggle"
    static let planSteps = "plan-steps"
    static let planProgress = "plan-progress"
    static let planStepPrefix = "plan-step-"
    static func planStep(_ index: Int) -> String { planStepPrefix + String(index) }
}

extension A11yID {
    static let queueChip = "queue-chip"
    static let queueSheet = "queue-sheet"
    static let queueRowPrefix = "queue-row-"
    static let queuePromotePrefix = "queue-promote-"
    static let queueRemovePrefix = "queue-remove-"
    static func queueRow(_ index: Int) -> String { queueRowPrefix + String(index) }
    static func queuePromote(_ id: String) -> String { queuePromotePrefix + id }
    static func queueRemove(_ id: String) -> String { queueRemovePrefix + id }
}

extension A11yID {
    static let reviewCouncil = "review-council"
    static let reviewCouncilMemberPrefix = "review-council-member-"
    static func reviewCouncilMember(_ provider: String) -> String {
        reviewCouncilMemberPrefix + provider.lowercased()
    }
}

extension A11yID {
    static func reviewFileAccept(patchId: String, filePath: String) -> String {
        reviewFileAcceptPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
    static func reviewFileReject(patchId: String, filePath: String) -> String {
        reviewFileRejectPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
}

extension A11yID {
    static func reviewFileKey(patchId: String, filePath: String) -> String {
        patchId + "-" + filePath.replacingOccurrences(of: "/", with: "--")
    }
}

extension A11yID {
    static func reviewFileRow(patchId: String, filePath: String) -> String {
        reviewFileRowPrefix + reviewFileKey(patchId: patchId, filePath: filePath)
    }
}

extension A11yID {
    static let reviewFindingsSection = "review-findings-section"
    static let reviewFindingAxisPrefix = "review-finding-axis-"
    static let reviewFindingRowPrefix = "review-finding-row-"
    static func reviewFindingAxis(_ axis: String) -> String { reviewFindingAxisPrefix + axis.lowercased() }
    static func reviewFindingRow(_ id: String) -> String { reviewFindingRowPrefix + id }
}

extension A11yID {
    static let reviewGovernance = "review-governance"
    static let reviewSheet = "review-sheet"
    static let reviewChipPrefix = "review-chip-"
    static func reviewChip(_ traceId: String) -> String { reviewChipPrefix + traceId }
}

extension A11yID {
    static let reviewPatchCardPrefix = "review-patch-card-"
    static let reviewPatchDiffPrefix = "review-patch-diff-"
    static let reviewAvailableContent = "review-available-content"
    static let reviewFileRowPrefix = "review-file-row-"
    static let reviewFileAcceptPrefix = "review-file-accept-"
    static let reviewFileRejectPrefix = "review-file-reject-"
    static func reviewPatchCard(_ patchId: String) -> String { reviewPatchCardPrefix + patchId }
    static func reviewPatchDiff(_ patchId: String) -> String { reviewPatchDiffPrefix + patchId }
}

extension A11yID {
    static let reviewControlsSection = "review-controls-section"
    static let reviewTestsSection = "review-tests-section"
    static let reviewDecidedSection = "review-decided-section"
    static let reviewRunAccept = "review-run-accept"
    static let reviewRunReject = "review-run-reject"
}

extension A11yID {
    static let reviewUnavailable = "review-unavailable"
    static let reviewEmpty = "review-empty"
    static let reviewLoadFailure = "review-load-failure"
    static let reviewDiffUnavailable = "review-diff-unavailable"
    static let reviewHashWarning = "review-hash-warning"
    static let reviewRunHeader = "review-run-header"
    static let reviewToast = "review-toast"
}

extension A11yID {
    static let searchScreen = "search-screen"
    static let searchField = "search-field"
    static let searchClear = "search-clear"
    static let searchRecentCaption = "search-recent-caption"
    static let searchResultsCaption = "search-results-caption"
    static let searchEmpty = "search-empty"
    static let searchLoading = "search-loading"
    static let searchOffline = "search-offline"
    static let searchResultPrefix = "search-result-"

    static func searchResult(_ threadId: String) -> String { searchResultPrefix + threadId }
}

extension A11yID {
    static let workspaceScreen = "workspace-screen"
    static let workspaceEmpty = "workspace-empty"
    static let workspaceLoading = "workspace-loading"
    static let workspaceOffline = "workspace-offline"
    static let workspaceRetry = "workspace-retry"
    static let workspaceThreadsCaption = "workspace-threads-caption"
    static let workspaceThreadPrefix = "workspace-thread-"
    static let workspaceAreaFilter = "workspace-area-filter"
    static let workspaceNewPill = "workspace-new-pill"

    static func workspaceThread(_ threadId: String) -> String { workspaceThreadPrefix + threadId }
}
