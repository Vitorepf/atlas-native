import SwiftUI
import AtlasCore

/// Achados agrupados pelo EIXO real que o servidor classificou
/// (`finding.category`) — a leitura por frente do mock, com dado verdadeiro.
/// Sem categoria, o achado cai em "gerais": nada é inventado.
struct ChangeReviewFindingsSection: View {
    let findings: [AtlasTraceChangeReview.Finding]

    private var groups: [String: [AtlasTraceChangeReview.Finding]] {
        Dictionary(grouping: findings) { $0.category?.uppercased() ?? "GERAIS" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChangeReviewCaption("ACHADOS · \(findings.count)")
            ForEach(groups.keys.sorted(), id: \.self) { axis in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                            .foregroundStyle(AtlasTheme.accent)
                        Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                        Text("\(groups[axis]?.count ?? 0)")
                            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    ForEach(groups[axis] ?? []) { f in
                        ChangeReviewFindingRow(finding: f)
                    }
                }
            }
        }
    }
}

struct ChangeReviewFindingRow: View {
    let finding: AtlasTraceChangeReview.Finding

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = finding.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(Self.severityColor(severity))
                }
                Text(finding.title ?? "finding").font(.footnote).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
            }
            if let path = finding.filePath {
                Text(path + (finding.startLine.map { ":\($0)" } ?? ""))
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
            }
            if let rec = finding.recommendation {
                Text(rec).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(3).padding(.top, 1)
            }
        }
        .padding(.vertical, 3)
    }

    /// A severidade é do servidor; a cor só traduz — nunca reclassifica.
    private static func severityColor(_ s: String) -> Color {
        switch s.lowercased() {
        case "critical", "high": return AtlasTheme.domOperacional
        case "medium": return AtlasTheme.accent
        default: return AtlasTheme.textTertiary
        }
    }
}
