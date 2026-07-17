import SwiftUI
import AtlasCore

// MARK: - Seções da ChangeReviewSheet (C15 · C18 · C19 · C21)
// Extraídas sem mudança de comportamento — a sheet só compõe.

/// C18 · C19 · C21 — as provas que o servidor emite. Cada bloco só existe
/// se a fonte existir: sem diff medido, sem replanejamento e sem conselho,
/// esta seção inteira desaparece (estado por exceção).
struct ChangeReviewGovernanceSection: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    var body: some View {
        if let trace = reviews.governanceByTrace[traceId] {
            let stats = AtlasTraceGovernance.diffStats(from: trace.metadata)
            let revisions = AtlasTraceGovernance.planRevisions(from: trace.metadata)
            let council = AtlasTraceGovernance.councilReview(from: trace.metadata)

            if stats != nil || !revisions.isEmpty || !council.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    if let stats {
                        HStack(spacing: 8) {
                            Image(systemName: "plusminus")
                                .font(.system(size: 11))
                                .foregroundStyle(AtlasTheme.textTertiary)
                            Text(stats.headline)
                                .font(AtlasFont.mono(11))
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .accessibilityLabel("\(stats.filesTouched) arquivos, mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
                        }
                    }

                    if let last = revisions.last {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 11))
                                .foregroundStyle(AtlasTheme.textTertiary)
                            Text(revisions.count == 1
                                 ? "plano v1 arquivado — \(last.humanReason)"
                                 : "\(revisions.count) versões de plano arquivadas — \(last.humanReason)")
                                .font(.system(size: 12))
                                .foregroundStyle(AtlasTheme.textSecondary)
                        }
                    }

                    if !council.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("Conselho")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                if AtlasTraceGovernance.councilDiverged(council) {
                                    // Divergência é FATO (status/hash distinto),
                                    // não veredito inventado pela casca.
                                    Text("divergência")
                                        .font(AtlasFont.mono(9))
                                        .foregroundStyle(AtlasTheme.accent)
                                }
                            }
                            ForEach(council) { member in
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 7) {
                                        Image(systemName: member.succeeded ? "checkmark" : "xmark")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
                                        Text(member.provider)
                                            .font(AtlasFont.mono(10))
                                            .foregroundStyle(AtlasTheme.textSecondary)
                                        if let model = member.model {
                                            Text(model)
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(AtlasTheme.textTertiary)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        Text(member.status)
                                            .font(AtlasFont.mono(9))
                                            .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
                                    }
                                    HStack(spacing: 8) {
                                        if let hash = member.responseHash {
                                            Text("hash \(String(hash.prefix(12)))")
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(AtlasTheme.textTertiary)
                                        }
                                        if let code = member.errorCode {
                                            Text(code)
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(Color(hex: 0xE08C8C))
                                        }
                                        if let latency = member.latencyMs {
                                            Text("\(latency)ms")
                                                .font(AtlasFont.mono(9))
                                                .foregroundStyle(AtlasTheme.textTertiary)
                                                .monospacedDigit()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier(A11yID.reviewGovernance)
            }
        }
    }
}

struct ChangeReviewRunHeader: View {
    let run: AtlasTraceChangeReview.Run

    var body: some View {
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
}

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?

    var body: some View {
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
                        Task { await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID) }
                    }
                }
                .font(.system(.footnote, weight: .medium)).foregroundStyle(AtlasTheme.accent)
            }
            ForEach(patch.changedFiles + patch.createdFiles + patch.deletedFiles, id: \.self) { file in
                ChangeReviewFileRow(reviews: reviews, traceId: traceId, patch: patch, file: file)
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
            if expandedDiffPatch == patch.id {
                ChangeReviewDiffView(reviews: reviews, traceId: traceId, patch: patch)
            }
        }
        .padding(14)
        .atlasCard()
    }
}

/// Estado por arquivo vem SÓ de patch.fileReviews; decidir chama o model
/// e a linha muda apenas quando o recibo voltar na projeção canônica.
struct ChangeReviewFileRow: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    let file: String

    private var decided: AtlasTraceChangeReview.FileReview? {
        patch.fileReviews.first { $0.filePath == file }
    }

    var body: some View {
        HStack(spacing: 8) {
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
                    Task { await reviews.applyChangeReviewFile(traceId: traceId, patchId: patch.patchID,
                                                             filePath: file, action: .accept) }
                }
                .font(.system(.caption, weight: .medium)).foregroundStyle(AtlasTheme.accent)
                Button("rejeitar") {
                    Task { await reviews.applyChangeReviewFile(traceId: traceId, patchId: patch.patchID,
                                                             filePath: file, action: .reject) }
                }
                .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .padding(.vertical, 3)
    }
}

struct ChangeReviewDiffView: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch

    var body: some View {
        if let response = reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID) {
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
}

struct ChangeReviewControlsSection: View {
    let controls: [AtlasTraceChangeReview.Control]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("CONTROLES")
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
}

struct ChangeReviewTestsSection: View {
    let tests: [AtlasTraceChangeReview.TestRun]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("TESTES")
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
}

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

struct ChangeReviewDecidedSection: View {
    let actions: [AtlasTraceChangeReview.OperatorAction]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChangeReviewCaption("DECISÕES REGISTRADAS")
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
}

/// Aceitar o run = aceitar todos os arquivos capturados e depois o run —
/// semântica do servidor; o botão só existe se a ação estiver disponível.
struct ChangeReviewRunActions: View {
    let review: AtlasTraceChangeReview
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Binding var applying: Bool

    var body: some View {
        let available = review.review.availableActions
        if !available.isEmpty {
            HStack(spacing: 10) {
                if available.contains(.accept) {
                    Button {
                        applying = true
                        Task { await reviews.applyChangeReview(traceId: traceId, action: .accept); applying = false }
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
                        Task { await reviews.applyChangeReview(traceId: traceId, action: .reject); applying = false }
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
}

struct ChangeReviewCaption: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text).font(AtlasFont.mono(10)).tracking(1.0).foregroundStyle(AtlasTheme.textTertiary)
    }
}

struct ChangeReviewToast: View {
    let reviews: ChangeReviewModel

    var body: some View {
        if let t = reviews.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    withAnimation(AtlasMotion.editorial) { reviews.toast = nil }
                }
        }
    }
}
