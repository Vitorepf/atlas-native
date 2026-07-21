import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: ThemeType fused

// MARK: - AtlasTheme

// MARK: - AtlasTheme

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

private struct AtlasCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let fillOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(AtlasTheme.surface.opacity(fillOpacity)))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

extension View {
    func atlasCard(cornerRadius: CGFloat = AtlasTheme.Radius.card, fillOpacity: Double = 1) -> some View {
        modifier(AtlasCardModifier(cornerRadius: cornerRadius, fillOpacity: fillOpacity))
    }
}

extension AtlasTheme {
    static let domOperacional = Color(hex: 0x9B7A3F) // bronze
    static let domAutonomos = Color(hex: 0x6FA06A)   // verde (moss clareado p/ dark)

    enum Space {
        static let screen: CGFloat = 20
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
    static let prussian = Color(hex: 0x7FA7C4)
    static let alert = Color(hex: 0xE08C8C)
}

extension AtlasTheme {
    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 12
        static let soft: CGFloat = 10
    }
}

extension AtlasTheme {
    static let bg = Color(hex: 0x1D2B34)
    static let bgRecessed = Color(hex: 0x15212A)
    static let surface = Color(hex: 0x243743)
    static let surfaceHi = Color(hex: 0x2D4351)
    static let separator = Color(hex: 0x313F47)
    static let separatorSoft = Color(hex: 0x27353E)
}

enum AtlasTheme {}
// MARK: - AtlasMotion

extension AtlasMotion {
    static func softImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func mediumImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func lightImpact(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

extension AtlasMotion {
    static func successNotification(reduceMotion: Bool) {
        guard !reduceMotion else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

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
    static func editorial(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : AtlasMotion.editorial
    }

    static func rowTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top))
    }
}

extension View {
    func atlasNumericTransition(reduceMotion: Bool) -> some View {
        modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}

enum AtlasMotion {
    static let instinct: Double = 0.18
    static let considered: Double = 0.32
    static let ceremonial: Double = 0.48
    static let sacred: Double = 0.62

    static let editorial = Animation.timingCurve(0.22, 1, 0.36, 1, duration: considered)
    static let arrival = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static func breath(_ duration: Double = 0.9) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}
// MARK: - AtlasGlassCircle

struct AtlasGlassCircle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Circle())
        } else {
            content.background(Circle().fill(AtlasTheme.surface))
        }
    }
}

struct AtlasGlassCapsule: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            // Fallback pré-26: recessed quieto (mockup home), não surface chapado.
            content.background(
                Capsule().fill(AtlasTheme.bgRecessed.opacity(0.82))
                    .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.9), lineWidth: 1)))
        }
    }
}

/// Chrome único da pílula agêntica = craft Home (lei pétrea pílula §2).
/// Vidro + fio de ouro artesanal. Só o convite muda por superfície.
struct AtlasAgenticPillChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Hit-test friendly fill sob glass no iOS 26 (identifier não some).
            .background { Capsule().fill(AtlasTheme.bgRecessed.opacity(0.01)) }
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(Self.goldFilament, lineWidth: 0.75)
            )
    }

    /// Fio de ouro da home — não goldBorder chapado, não shadow solto.
    static var goldFilament: LinearGradient {
        LinearGradient(
            colors: [
                AtlasTheme.accent.opacity(0.22),
                AtlasTheme.accent.opacity(0.04),
                AtlasTheme.accent.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func atlasGlassCircle() -> some View { modifier(AtlasGlassCircle()) }
    /// Mesma lei para pílulas/cápsulas de chrome (composer da home, new pill).
    func atlasGlassCapsule() -> some View { modifier(AtlasGlassCapsule()) }
    /// Chrome canônico da pílula: glass + fio de ouro Home. Use em toda superfície.
    func atlasAgenticPillChrome() -> some View { modifier(AtlasAgenticPillChrome()) }
}
// MARK: - AtlasType

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

@MainActor
enum AtlasSansScale {
    private static var table: [UIFont.TextStyle: [DynamicTypeSize: CGFloat]] = [:]

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

enum AtlasFont {
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

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom(weight == .medium ? "JetBrainsMono-Medium" : "JetBrainsMono-Regular",
                size: size, relativeTo: anchor(size))
    }
}

// MARK: - AtlasInteraction

// MARK: - PressableScale

struct PressableScale: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.96 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.6)),
                value: configuration.isPressed
            )
    }
}
// MARK: - SwipeBackEnabler

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    /// Só permite o pop quando há para onde voltar — a raiz nunca trava.
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
// MARK: - NavigationInteractivePopEnabler

struct NavigationInteractivePopEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Controller()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        (uiViewController as? Controller)?.enablePopIfNeeded()
    }

    private final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            enablePopIfNeeded()
        }

        func enablePopIfNeeded() {
            guard let nav = navigationController else { return }
            nav.interactivePopGestureRecognizer?.isEnabled = nav.viewControllers.count > 1
        }
    }
}

// MARK: - Close toolbar

struct AtlasCloseToolbarButton: View {
    var title: String = "Fechar"
    let spokenLabel: String
    var spokenHint: String = ""
    var accessibilityID: String? = nil
    let reduceMotion: Bool
    let action: () -> Void

    var body: some View {
        Button(title) {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        }
        .tint(AtlasTheme.textSecondary)
        .accessibilityLabel(spokenLabel)
        .accessibilityHint(spokenHint)
        .modifier(CloseToolbarA11yID(accessibilityID))
    }
}

struct CloseToolbarA11yID: ViewModifier {
    let id: String?
    init(_ id: String?) { self.id = id }
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}

// MARK: - AtlasPresentationUtils

// MARK: - LoadPhase

enum LoadPhase: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
// MARK: - StringNonEmpty

extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
// MARK: - AtlasAreaOf

extension AtlasArea {
    static func of(_ t: AtlasAiThread) -> AtlasArea {
        let surface = t.surface.lowercased()
        let mode = (t.metadata?["current_mode"]?.stringValue
            ?? t.metadata?["atlas_mode"]?.stringValue
            ?? t.metadata?["workflow_mode"]?.stringValue ?? "").lowercased()
        let domain = (t.metadata?["routing_domain"]?.stringValue ?? "").lowercased()
        if surface.contains("code") || domain.contains("eng") || domain.contains("prog") || mode.contains("program") {
            return .programacao
        }
        if mode.contains("auto") || mode.contains("loop") || (t.metadata?["awis_automation"]?.boolValue ?? false) {
            return .autonomos
        }
        return .operacional
    }
}
// MARK: - LiveSessionSnapshot

struct LiveSessionSnapshot: Identifiable, Equatable {
    let id: String            // traceId corrente (estável por execução)
    let threadId: ThreadID?   // para Route.thread; nil se conversa nova local
    let title: String
    let phaseTitle: String
    let timing: AtlasExecutionPresence.Timing
    let elapsedActiveMs: Int?
    let runningSince: Date?
    let pauseTimestamp: Date?
    /// 1ª observação local — só ordenação; nunca exibido como duração.
    let startedAt: Date
    let isRemote: Bool
}
// MARK: - AtlasUserMessage

func atlasUserMessage(forAPI error: Error) -> String? {
    guard let api = error as? AtlasApiError else { return nil }
    switch api.status {
    case 401, 403: return "A sessão do Atlas precisa ser reconectada."
    case 408, 429: return "O Atlas está ocupado. Este turno continua recuperável."
    case 500...599: return "O servidor Atlas está temporariamente indisponível."
    default: return api.message
    }
}

func atlasUserMessage(forStream error: Error) -> String? {
    guard error is AtlasInteractionStreamError else { return nil }
    return "A conexão com a execução caiu. O Atlas retomará este turno automaticamente."
}

func atlasUserMessage(forURL error: Error) -> String? {
    guard let urlError = error as? URLError else { return nil }
    switch urlError.code {
    case .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost,
         .cannotFindHost, .timedOut:
        return "A conexão caiu. O Atlas vai recuperar este turno quando a rede voltar."
    default:
        return "Não foi possível falar com o Atlas agora. Tente novamente."
    }
}

func atlasUserMessage(for error: Error) -> String {
    if let message = atlasUserMessage(forStream: error) { return message }
    if let message = atlasUserMessage(forURL: error) { return message }
    if let message = atlasUserMessage(forAPI: error) { return message }
    return "A execução foi interrompida. Tente novamente."
}
// MARK: - AtlasWorkspace

struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }
}

extension AtlasArea {
    var label: String {
        labelDomain ?? "Tudo"
    }
}

extension AtlasArea {
    var labelDomain: String? {
        switch self {
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        default: return nil
        }
    }
}
// MARK: - AtlasConventionalCommit

enum AtlasConventionalCommit {
    // ponytail: whitelist de tipos — evita falso-positivo de mensagem comum
    // com ":" ("nota: isso"). Cobre os tipos usados no Atlas + os padrão.
    private static let knownTypes: Set<String> = [
        "feat", "fix", "docs", "polish", "refactor", "chore",
        "test", "style", "perf", "build", "ci", "revert", "wip"
    ]

    /// `type` normalizado: minúsculo, PRIMEIRO segmento com escopo
    /// ("fix(ui)+polish(ui)" → "fix(ui)"); nil quando não-convencional.
    static func split(_ message: String) -> (type: String?, subject: String) {
        guard let sep = message.range(of: ": ") else { return (nil, message) }
        let head = String(message[..<sep.lowerBound])
        let subject = String(message[sep.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !subject.isEmpty, let type = conventionalType(head) else { return (nil, message) }
        return (type, subject)
    }

    private static func conventionalType(_ head: String) -> String? {
        guard !head.isEmpty, head.count <= 40, !head.contains(" ") else { return nil }
        // Primeiro segmento (antes de '+'): o tipo primário do commit.
        let segment = head.split(separator: "+", maxSplits: 1).first.map(String.init) ?? head
        let typeWord = segment.prefix { $0.isLetter }
        let remainder = segment[typeWord.endIndex...]
        // O resto do segmento tem de ser escopo/marca VÁLIDA ("(...)", "!" ou
        // vazio) — senão "fix-me"/"ci-cd" viraria tipo (falso-positivo).
        guard knownTypes.contains(typeWord.lowercased()), isValidScope(remainder) else { return nil }
        return typeWord.lowercased() + remainder
    }

    private static func isValidScope(_ raw: Substring) -> Bool {
        var s = raw
        if s.hasSuffix("!") { s = s.dropLast() }
        if s.isEmpty { return true }
        return s.first == "(" && s.last == ")"
    }
}
