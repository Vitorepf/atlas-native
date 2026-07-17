import SwiftUI
import AtlasCore

/// Achados agrupados pelo EIXO real que o servidor classificou
/// (`finding.category`) — a leitura por frente do mock, com dado verdadeiro.
/// Sem categoria, o achado cai em "gerais": nada é inventado.
/// Axis → ChangeReviewFindingsSection+Axis.swift
struct ChangeReviewFindingsSection: View {
    let findings: [AtlasTraceChangeReview.Finding]

    var groups: [String: [AtlasTraceChangeReview.Finding]] {
        Dictionary(grouping: findings) { $0.category?.uppercased() ?? "GERAIS" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ChangeReviewCaption("ACHADOS · \(findings.count)")
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("achados, \(findings.count) no total")
            ForEach(groups.keys.sorted(), id: \.self) { axis in
                axisGroup(axis: axis, axisFindings: groups[axis] ?? [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.reviewFindingsSection)
    }
}
