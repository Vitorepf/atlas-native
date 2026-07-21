import SwiftUI
import AtlasCore
import Charts

// GOD-RESTRUCTURE: ArenaPremium primitives + chrome bits fused

// MARK: - Kicker

struct ArenaPremiumKicker: View {
    let text: String
    var tone: ArenaPremiumTone = .neutral
    /// Live: ✦ que respira (nunca bola). Demais kickers sem marca.
    var showsLiveMark = false

    var body: some View {
        HStack(spacing: 8) {
            if showsLiveMark {
                Text("✦")
                    .font(AtlasFont.serif(11))
                    .foregroundStyle(tone.color)
                    .modifier(ArenaLiveBreath())
                    .accessibilityHidden(true)
            }
            Text(text.uppercased())
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.6)
                .foregroundStyle(tone.color)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Compat: kickers antigos com `showsDot:` viram marca ✦ quando true.
extension ArenaPremiumKicker {
    init(text: String, tone: ArenaPremiumTone = .neutral, showsDot: Bool) {
        self.init(text: text, tone: tone, showsLiveMark: showsDot)
    }
}

private struct ArenaLiveBreath: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1 : (on ? 1 : 0.55))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(AtlasMotion.breath(2.4)) { on = true }
            }
    }
}

// MARK: - Hairline · action

struct ArenaPremiumHairline: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [AtlasTheme.separator.opacity(0.2), AtlasTheme.separator, AtlasTheme.separator.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumAction: View {
    let title: String
    var symbol: String? = nil
    var tone: ArenaPremiumTone = .neutral
    var quiet = false
    var disabled = false
    let action: () -> Void

    /// Compat com call sites que passam SF Symbol.
    init(
        title: String,
        symbol: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = symbol
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    init(
        title: String,
        tone: ArenaPremiumTone = .neutral,
        quiet: Bool = false,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.symbol = nil
        self.tone = tone
        self.quiet = quiet
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .atlasSans(14, quiet ? .regular : .medium)
                .frame(maxWidth: .infinity, minHeight: 46)
                .padding(.horizontal, 20)
                .foregroundStyle(disabled ? AtlasTheme.textTertiary : (quiet ? AtlasTheme.textSecondary : AtlasTheme.textPrimary))
                .background(
                    Capsule().fill(
                        quiet || disabled
                            ? Color.clear
                            : Color.white.opacity(0.055)
                    )
                )
                .overlay(
                    Capsule().stroke(
                        quiet
                            ? AtlasTheme.separator.opacity(disabled ? 0.35 : 0.7)
                            : Color.white.opacity(disabled ? 0.04 : 0.08),
                        lineWidth: 1
                    )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PressableScale())
        .disabled(disabled)
        .accessibilityLabel(title)
    }
}

// MARK: - Disclosure · ring · empty

struct ArenaPremiumDisclosureRow: View {
    let title: String
    let detail: String
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ArenaPremiumIcon(symbol: symbol, tone: tone)
                // Linha de lista fala sans (canon §C — serif é masthead/título);
                // mesma lei aplicada no Código e nos Artifacts hoje.
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                ArenaPremiumChevron()
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ArenaPremiumProgressRing: View {
    let progress: Double?
    let percentage: Int?

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .trim(from: 0.08, to: 0.92)
                    .stroke(Color.white.opacity(0.06), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                if let progress {
                    Circle()
                        .trim(from: 0.08, to: 0.08 + 0.84 * min(max(progress, 0), 1))
                        .stroke(AtlasTheme.accent, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                }
            }
            .rotationEffect(.degrees(90))
            if let percentage {
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text("\(percentage)")
                        .font(AtlasFont.serif(42))
                    Text("%")
                        .font(AtlasFont.mono(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .baselineOffset(4)
                }
                .foregroundStyle(AtlasTheme.textPrimary)
            } else {
                Text("✦")
                    .font(AtlasFont.serif(24))
                    .foregroundStyle(AtlasTheme.accent)
            }
        }
        .frame(width: 142, height: 142)
        .accessibilityHidden(true)
    }
}

struct ArenaPremiumEmptyGlyph: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral

    var body: some View {
        ArenaPremiumIcon(symbol: symbol, tone: tone, role: .hero)
            .background(Circle().fill(AtlasTheme.surface.opacity(0.72)))
            .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}
// MARK: - ArenaPremiumIcon

enum ArenaPremiumIconRole {
    case compact
    case standard
    case hero

    var pointSize: CGFloat {
        switch self {
        case .compact: 12
        case .standard: 17
        case .hero: 28
        }
    }

    var box: CGFloat {
        switch self {
        case .compact: 16
        case .standard: 24
        case .hero: 68
        }
    }
}

/// The only renderer for symbols inside the Arena surface.
struct ArenaPremiumIcon: View {
    let symbol: String
    var tone: ArenaPremiumTone = .neutral
    var role: ArenaPremiumIconRole = .standard

    var body: some View {
        Image(systemName: symbol)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: role.pointSize, weight: .medium))
            .foregroundStyle(tone.color)
            .frame(width: role.box, height: role.box, alignment: .center)
            .accessibilityHidden(true)
    }
}

struct ArenaPremiumChevron: View {
    var body: some View {
        ArenaPremiumIcon(
            symbol: ArenaPremiumIconography.disclosure,
            tone: .muted,
            role: .compact
        )
    }
}

enum ArenaPremiumIconography {
    static let action = "play.fill"
    static let add = "plus"
    static let alerts = "exclamationmark.triangle"
    static let blocked = "lock"
    static let comparison = "arrow.right"
    static let coverage = "checkmark.seal"
    static let disclosure = "chevron.right"
    static let execution = "list.bullet.rectangle"
    static let next = "calendar.badge.clock"
    static let plan = "list.bullet.rectangle"
    static let queue = "tray.full"
    static let stop = "stop.fill"
    static let verified = "checkmark.shield"

    static func run(_ status: AtlasArenaRunStatus) -> String {
        ArenaRunStatusJudgment.sfSymbol(for: status)
    }

    static func planStatus(_ status: AtlasArenaRunStatus?) -> String {
        guard let status else { return "circle" }
        return ArenaRunStatusJudgment.sfSymbol(for: status)
    }

    static func suite(_ suite: String) -> String {
        switch suite {
        case "terminal_bench": "terminal"
        case "bfcl": "wrench.and.screwdriver"
        case "inspect_evals": "arrow.triangle.2.circlepath"
        case "tau2_bench": "function"
        case "live_code_bench", "swe_bench_live":
            "chevron.left.forwardslash.chevron.right"
        default: "diamond"
        }
    }
}
// MARK: - ArenaPremiumTabBar

struct ArenaPremiumTabBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var selection: ArenaPremiumTab
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ArenaPremiumTab.allCases) { tab in
                Button {
                    withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { selection = tab }
                } label: {
                    // Controle fala sans (canon §C); seleção = pílula neutra
                    // ELEVADA (padrão do segmented nativo), não véu de ouro —
                    // ouro é ESTADO, não seleção de controle.
                    Text(tab.rawValue)
                        .atlasSans(13, .medium)
                        .foregroundStyle(selection == tab ? AtlasTheme.textPrimary : AtlasTheme.textTertiary)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background {
                            if selection == tab {
                                Capsule()
                                    .fill(AtlasTheme.surfaceHi)
                                    .shadow(color: .black.opacity(0.22), radius: 5, y: 1)
                                    .matchedGeometryEffect(id: "arena-tab", in: selectionNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tabAccessibilityLabel(tab))
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
                .accessibilityIdentifier(A11yID.arenaPremiumTab(tab.a11yKey))
            }
        }
        .padding(3)
        .background(Capsule().fill(AtlasTheme.bgRecessed.opacity(0.92)))
        .overlay(Capsule().stroke(AtlasTheme.separator.opacity(0.7), lineWidth: 1))
    }

    private func tabAccessibilityLabel(_ tab: ArenaPremiumTab) -> String {
        switch tab {
        case .now: "Agora"
        case .fleet: "Frota"
        case .capabilities: "Capacidades"
        case .results: "Motor"
        }
    }
}
// MARK: - ArenaPremiumChrome

struct ArenaPremiumEngineTitle: View {
    let engineID: String
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        if options.count > 1 {
            Menu {
                ForEach(options, id: \.self) { engine in
                    Button {
                        onSelect(engine)
                    } label: {
                        if engine == engineID {
                            Label(ArenaDisplay.engine(engine), systemImage: "checkmark")
                        } else {
                            Text(ArenaDisplay.engine(engine))
                        }
                    }
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(ArenaDisplay.engine(engineID))
                        .font(AtlasFont.serif(33))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityLabel(ArenaScoreJudgment.spokenMeasuredEngine(engineID))
            .accessibilityHint(ArenaScoreJudgment.measuredEngineHint)
            .accessibilityIdentifier(A11yID.arenaPremiumEnginePicker)
        } else {
            Text(ArenaDisplay.engine(engineID))
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
        }
    }
}
// MARK: - ArenaPremiumLoadFailureView

struct ArenaPremiumLoadFailureView: View {
    @Bindable var model: ArenaModel

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: model.isDomainUnavailable
                ? .domainUnavailable
                : .load(
                    headline: "Não foi possível carregar a medição",
                    message: "A tela não transformou a falha de rede em estado vazio."
                ),
            layout: .leadingEditorial,
            kicker: model.isDomainUnavailable ? "Arena não publicada" : "Arena indisponível",
            symbol: model.isDomainUnavailable ? "shippingbox" : "wifi.exclamationmark",
            topPadding: 0,
            accessibilityIdentifier: A11yID.arenaPremiumState("failed-load"),
            retryHint: "tenta carregar a Arena de novo",
            onRetry: { Task { await model.load() } }
        )
    }
}
// MARK: - ArenaPremiumGlyphRow

struct ArenaPremiumGlyphRow: View {
    let glyph: String
    let title: String
    let detail: String
    var tone: ArenaPremiumTone = .neutral
    var glyphTone: ArenaPremiumTone? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(glyph)
                    .font(AtlasFont.serif(14))
                    .foregroundStyle((glyphTone ?? tone).color)
                    .frame(width: 22, alignment: .center)
                    .accessibilityHidden(true)
                Text(title)
                    .atlasSans(16, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 12)
                Text(detail)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(tone.color)
                    .lineLimit(1)
                Text("›")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ArenaPremiumOperationalRows: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    private var alertCount: Int { model.arenaAlertSuiteCount }

    var body: some View {
        // Sem exceção: some a seção. Fila/Cobertura/Próxima/Plano moram
        // DENTRO de Execução — duplicar aqui era a confusão.
        if alertCount > 0 {
            VStack(spacing: 0) {
                ArenaPremiumHairline()
                ArenaPremiumGlyphRow(
                    glyph: "※",
                    title: "Alertas",
                    detail: alertCount == 1 ? "1 exceção" : "\(alertCount) exceções",
                    tone: .negative,
                    glyphTone: .negative
                ) { onNavigate(.alerts) }
                .accessibilityIdentifier(A11yID.arenaPremiumAlertsAction)
            }
        }
    }
}
// MARK: - ArenaToggleSymbolBounce

struct ArenaToggleSymbolBounce: ViewModifier {
    let enabled: Bool
    let isOn: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.symbolEffect(.bounce, value: isOn)
        } else {
            content
        }
    }
}
// MARK: - ArenaFormat

enum ArenaFormat {
    private static let scoreStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(0...1))

    private static let multiplierStyle = FloatingPointFormatStyle<Double>.number
        .locale(Locale(identifier: "pt_BR"))
        .grouping(.never)
        .precision(.fractionLength(2))

    static func score(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.score(value) else {
            return "não medido"
        }
        return value.formatted(scoreStyle)
    }

    static func signed(_ value: Double?) -> String {
        guard let value = AtlasArenaPresentationScale.delta(value) else {
            return "—"
        }
        if abs(value) < 0.05 {
            return "0"
        }
        return "\(value > 0 ? "+" : "")\(value.formatted(scoreStyle))"
    }

    static func multiplier(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "×\(value.formatted(multiplierStyle))"
    }
}
// MARK: - ArenaSuiteSparkline

extension AtlasArenaSuite {
    var arenaSubtitleText: String {
        guard isMeasured else { return "não medido" }
        let rounds = runsTotal == 1 ? "1 rodada" : "\(runsTotal) rodadas"
        if let relative = ArenaDisplay.relative(lastRunAt) { return "\(rounds) · \(relative)" }
        return rounds
    }
}

struct SuiteSparkline: View {
    let engine: AtlasArenaSuiteEngine

    var body: some View {
        Chart(engine.history) { point in
            if let score = point.score {
                LineMark(x: .value("rodada", point.roundAt), y: .value("score", score))
                    .foregroundStyle(point.arm == .withAtlas ? AtlasTheme.accent : AtlasTheme.textSecondary)
                    .interpolationMethod(.linear)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .accessibilityHidden(true)
    }
}

// MARK: - Composite chart

struct ArenaCompositeChart: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var interpolation: InterpolationMethod { reduceMotion ? .linear : .catmullRom }

    var body: some View {
        Chart {
            historyMarks
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYScale(domain: fittedYDomain)
        .chartYAxis { AxisMarks(position: .leading) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteJudgment.spokenCompositeChart(engine))
    }

    /// Domínio ajustado ao dado: eixo fixo 0–1 espremia as linhas.
    var fittedYDomain: ClosedRange<Double> {
        let values = engine.history.flatMap { [$0.composite, $0.withAtlas, $0.withoutAtlas].compactMap { $0 } }
        guard let lo = values.min(), let hi = values.max(), hi > lo else { return 0 ... 1 }
        let pad = max(0.04, (hi - lo) * 0.3)
        return max(0, lo - pad) ... min(1, hi + pad)
    }

    @ChartContentBuilder
    var historyMarks: some ChartContent {
        ForEach(engine.history) { point in
            if let composite = point.composite {
                LineMark(x: .value("rodada", point.roundAt), y: .value("composto", composite))
                    .foregroundStyle(AtlasTheme.accent)
                    .interpolationMethod(interpolation)
            }
            if let withAtlas = point.withAtlas {
                LineMark(
                    x: .value("rodada", point.roundAt),
                    y: .value("com Atlas", withAtlas),
                    series: .value("série", "com Atlas")
                )
                .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                .interpolationMethod(interpolation)
            }
            if let withoutAtlas = point.withoutAtlas {
                LineMark(
                    x: .value("rodada", point.roundAt),
                    y: .value("sem Atlas", withoutAtlas),
                    series: .value("série", "sem Atlas")
                )
                .foregroundStyle(AtlasTheme.textSecondary)
                .interpolationMethod(interpolation)
            }
        }
    }
}
