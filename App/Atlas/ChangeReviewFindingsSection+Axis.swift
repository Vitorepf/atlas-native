import SwiftUI
import AtlasCore

// Axis group — peel de ChangeReviewFindingsSection.

extension ChangeReviewFindingsSection {
    func axisGroup(axis: String, axisFindings: [AtlasTraceChangeReview.Finding]) -> some View {
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

    func axisHeaderLabel(axis: String, count: Int) -> String {
        let name = axis == "GERAIS" ? "gerais" : axis.lowercased()
        let noun = count == 1 ? "achado" : "achados"
        return "eixo \(name), \(count) \(noun)"
    }
}
