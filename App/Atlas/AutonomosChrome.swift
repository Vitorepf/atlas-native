import SwiftUI

/// Presentation-only chrome shared by Autônomos sections (internal, not public).
enum AutonomosChrome {
    @ViewBuilder
    static func sectionCaption(_ t: String) -> some View {
        Text(t)
            .font(.system(.caption, weight: .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
    }

    @ViewBuilder
    static func tag(_ t: String) -> some View {
        Text(t)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
    }

    @ViewBuilder
    static func digestChip(_ value: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Text(value).font(AtlasFont.mono(14)).foregroundStyle(AtlasTheme.accent)
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, 9).padding(.vertical, 6)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
    }

    static func uptime(_ seconds: Int) -> String {
        if seconds >= 86_400 { return "\(seconds / 86_400)d \((seconds % 86_400) / 3600)h" }
        if seconds >= 3600 { return "\(seconds / 3600)h \((seconds % 3600) / 60)m" }
        return "\(seconds / 60)m"
    }

    static func relativeAge(from date: Date, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        let days = seconds / 86_400
        if days > 0 { return days == 1 ? "1 dia" : "\(days) dias" }
        let hours = seconds / 3_600
        if hours > 0 { return "\(hours)h" }
        return "\(max(1, seconds / 60))min"
    }
}

struct FleetMetric: View {
    let value: String; let label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(AtlasFont.mono(18)).foregroundStyle(AtlasTheme.textPrimary)
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(11)
        .atlasCard(cornerRadius: 12)
    }
}

struct DetailMetric: View {
    let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(AtlasFont.mono(15)).foregroundStyle(AtlasTheme.textPrimary)
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AutonomosPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.accent.opacity(configuration.isPressed ? 0.72 : 1)))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct AutonomosSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surfaceHi))
            .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

struct AutonomosDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
    }
}
