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
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("achados, \(findings.count) no total")
            ForEach(groups.keys.sorted(), id: \.self) { axis in
                let axisFindings = groups[axis] ?? []
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                            .foregroundStyle(AtlasTheme.accent)
                        Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                        Text("\(axisFindings.count)")
                            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel(axisHeaderLabel(axis: axis, count: axisFindings.count))
                    .accessibilityIdentifier(A11yID.reviewFindingAxis(axis))
                    ForEach(axisFindings) { f in
                        ChangeReviewFindingRow(finding: f)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewFindingsSection)
    }

    private func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}
