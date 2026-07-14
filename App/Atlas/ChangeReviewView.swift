import SwiftUI
import AtlasCore

// C15 — Revisar mudanças de uma execução (o "Review" da cena 12, real).
// A casca renderiza SOMENTE model.changeReviewsByTrace[traceId]:
// `unavailable` é um estado explícito com motivo (sem arquivos/botões);
// `available` traz patches, controles, testes e findings persistidos.
// Aceitar/rejeitar só muda a tela depois do recibo do servidor (o model
// garante); diff vem por refreshChangeReviewDiff — nunca rede na View.
struct ChangeReviewSheet: View {
    let model: ConversationModel
    let traceId: String
    @Environment(\.dismiss) private var dismiss
    @State private var expandedDiffPatch: String?
    @State private var applying = false

    private var review: AtlasTraceChangeReview? { model.changeReviewsByTrace[traceId] }

    var body: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("Revisar mudanças")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Fechar") { dismiss() } }
            }
        }
        .task { await model.refreshChangeReview(traceId: traceId) }
    }

    @ViewBuilder
    private var content: some View {
        if let review {
            switch review.state {
            case .unavailable:
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2).foregroundStyle(AtlasTheme.textTertiary)
                    Text("Sem artefatos de revisão nesta execução.")
                        .font(AtlasFont.serif(18, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    if let reason = review.reason {
                        Text(reason).font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(36)
            case .available:
                available(review)
            }
        } else {
            VStack(spacing: 14) {
                ProgressView().tint(AtlasTheme.accent)
                Text("consultando a revisão…")
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    private func available(_ review: AtlasTraceChangeReview) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if let run = review.run { runHeader(run) }
                ForEach(review.patches) { patch in patchCard(patch) }
                if !review.controls.isEmpty { controlsSection(review.controls) }
                if !review.testRuns.isEmpty { testsSection(review.testRuns) }
                if !review.review.findings.isEmpty { findingsSection(review.review.findings) }
                if !review.review.operatorActions.isEmpty {
                    decidedSection(review.review.operatorActions)
                }
                runActions(review)
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 14)
        }
        .scrollIndicators(.hidden)
    }

    private func runHeader(_ run: AtlasTraceChangeReview.Run) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(run.decision ?? run.status ?? "revisão")
                    .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                if let finished = run.finishedAt {
                    Text(finished).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                }
            }
            Spacer()
            if let score = run.score {
                Text("\(score)").font(AtlasFont.mono(20)).foregroundStyle(AtlasTheme.accent)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }

    private func patchCard(_ patch: AtlasTraceChangeReview.Patch) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PATCH \(String(patch.id.prefix(8)))")
                    .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
                Button(expandedDiffPatch == patch.id ? "Fechar diff" : "Ver diff") {
                    if expandedDiffPatch == patch.id {
                        expandedDiffPatch = nil
                    } else {
                        expandedDiffPatch = patch.id
                        Task { await model.refreshChangeReviewDiff(traceId: traceId, patchId: patch.id) }
                    }
                }
                .font(.system(.footnote, weight: .medium)).foregroundStyle(AtlasTheme.accent)
            }
            ForEach(patch.changedFiles + patch.createdFiles + patch.deletedFiles, id: \.self) { file in
                fileRow(patch: patch, file: file)
            }
            if !patch.riskFlags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(patch.riskFlags, id: \.self) { flag in
                        Text(flag).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domOperacional)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                    }
                }
            }
            if expandedDiffPatch == patch.id { diffView(patch) }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }

    /// Estado por arquivo vem SÓ de patch.fileReviews; decidir chama o model
    /// e a linha muda apenas quando o recibo voltar na projeção canônica.
    private func fileRow(patch: AtlasTraceChangeReview.Patch, file: String) -> some View {
        let decided = patch.fileReviews.first { $0.filePath == file }
        return HStack(spacing: 8) {
            Text((file as NSString).lastPathComponent)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            if patch.createdFiles.contains(file) {
                Text("novo").font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domAutonomos)
            } else if patch.deletedFiles.contains(file) {
                Text("removido").font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domOperacional)
            }
            Spacer()
            if let decided {
                Text(decided.action == .accept ? "aceito" : "rejeitado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(decided.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            } else {
                Button("aceitar") {
                    Task { await model.applyChangeReviewFile(traceId: traceId, patchId: patch.id,
                                                             filePath: file, action: .accept) }
                }
                .font(.system(.caption, weight: .medium)).foregroundStyle(AtlasTheme.accent)
                Button("rejeitar") {
                    Task { await model.applyChangeReviewFile(traceId: traceId, patchId: patch.id,
                                                             filePath: file, action: .reject) }
                }
                .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .padding(.vertical, 3)
    }

    @ViewBuilder
    private func diffView(_ patch: AtlasTraceChangeReview.Patch) -> some View {
        if let response = model.changeReviewDiff(traceId: traceId, patchId: patch.id) {
            VStack(alignment: .leading, spacing: 6) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(response.diff.content)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .textSelection(.enabled)
                        .padding(10)
                }
                .frame(maxHeight: 320)
                .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.bgRecessed))
                if response.diff.truncated {
                    Text("diff truncado — \(response.diff.returnedBytes) de \(response.diff.sizeBytes) bytes")
                        .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                }
                if response.patch.hashMatches == false {
                    Text("atenção: o hash do diff não confere com o artefato registrado")
                        .font(.caption).foregroundStyle(AtlasTheme.domOperacional)
                }
            }
        } else {
            ProgressView().tint(AtlasTheme.accent).padding(.vertical, 8)
        }
    }

    private func controlsSection(_ controls: [AtlasTraceChangeReview.Control]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            caption("CONTROLES")
            ForEach(controls) { c in
                HStack(spacing: 8) {
                    Text(c.slug).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textPrimary)
                    Text(c.status).font(AtlasFont.mono(10))
                        .foregroundStyle(c.status == "pass" ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                    Spacer()
                    Text(c.signalSummary).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
                }
            }
        }
    }

    private func testsSection(_ tests: [AtlasTraceChangeReview.TestRun]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            caption("TESTES")
            ForEach(tests) { t in
                HStack(spacing: 8) {
                    Text(t.command ?? "teste").font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                    Spacer()
                    Text(t.status).font(AtlasFont.mono(10))
                        .foregroundStyle(t.status == "passed" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                }
            }
        }
    }

    /// Achados agrupados pelo EIXO real que o servidor classificou
    /// (`finding.category`) — a leitura por frente do mock, com dado verdadeiro.
    /// Sem categoria, o achado cai em "gerais": nada é inventado.
    private func findingsSection(_ findings: [AtlasTraceChangeReview.Finding]) -> some View {
        let groups = Dictionary(grouping: findings) { $0.category?.uppercased() ?? "GERAIS" }
        return VStack(alignment: .leading, spacing: 10) {
            caption("ACHADOS · \(findings.count)")
            ForEach(groups.keys.sorted(), id: \.self) { axis in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(axis).font(AtlasFont.mono(9)).tracking(0.8)
                            .foregroundStyle(AtlasTheme.accent)
                        Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                        Text("\(groups[axis]?.count ?? 0)")
                            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    ForEach(groups[axis] ?? []) { f in findingRow(f) }
                }
            }
        }
    }

    private func findingRow(_ f: AtlasTraceChangeReview.Finding) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                if let severity = f.severity {
                    Text(severity).font(AtlasFont.mono(9))
                        .foregroundStyle(Self.severityColor(severity))
                }
                Text(f.title ?? "finding").font(.footnote).foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
            }
            if let path = f.filePath {
                Text(path + (f.startLine.map { ":\($0)" } ?? ""))
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
            }
            if let rec = f.recommendation {
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

    private func decidedSection(_ actions: [AtlasTraceChangeReview.OperatorAction]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            caption("DECISÕES REGISTRADAS")
            ForEach(actions) { a in
                HStack(spacing: 8) {
                    Text(a.action == .accept ? "aceito" : "rejeitado")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(a.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    if let at = a.actedAt {
                        Text(at).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    Spacer()
                }
            }
        }
    }

    /// Aceitar o run = aceitar todos os arquivos capturados e depois o run —
    /// semântica do servidor; o botão só existe se a ação estiver disponível.
    @ViewBuilder
    private func runActions(_ review: AtlasTraceChangeReview) -> some View {
        let available = review.review.availableActions
        if !available.isEmpty {
            HStack(spacing: 10) {
                if available.contains(.accept) {
                    Button {
                        applying = true
                        Task { await model.applyChangeReview(traceId: traceId, action: .accept); applying = false }
                    } label: {
                        Text("Aceitar tudo")
                            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Capsule().fill(AtlasTheme.accent))
                    }
                }
                if available.contains(.reject) {
                    Button {
                        applying = true
                        Task { await model.applyChangeReview(traceId: traceId, action: .reject); applying = false }
                    } label: {
                        Text("Rejeitar")
                            .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
                            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
                    }
                }
                if applying { ProgressView().tint(AtlasTheme.accent) }
            }
            .disabled(applying)
            .padding(.top, 4)
        }
    }

    private func caption(_ t: String) -> some View {
        Text(t).font(AtlasFont.mono(10)).tracking(1.0).foregroundStyle(AtlasTheme.textTertiary)
    }
}
