import AtlasCore
import PhotosUI
import SwiftUI

// Cycle 044 fuse → ConversationChrome.swift

struct OptionalAccessibilityIdentifier: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}

extension SheetShell {
    var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
            .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
            .accessibilityHidden(true)
    }

    var sheetTitle: some View {
        Text(title)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.bottom, 14)
            .accessibilityAddTraits(.isHeader)
    }
}

extension SheetShell {
    func sheetPresentationChrome<Inner: View>(_ content: Inner) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .presentationDetents([.medium, .large])
            .presentationBackground(AtlasTheme.bg)
            .presentationDragIndicator(.hidden)
    }
}

extension SheetShell {
    var sheetScrollBody: some View {
        VStack(spacing: 0) {
            sheetHandle
            sheetTitle
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
    }
}

/// Rótulo composto só com label/sub publicados; seleção explícita.

enum SheetShellA11y {
    static func spokenRow(label: String, sub: String?, selected: Bool) -> String {
        var parts = [label]
        if let sub, !sub.isEmpty { parts.append(sub) }
        parts.append(selected ? "selecionado" : "disponível")
        return parts.joined(separator: ", ")
    }
}

// Shell compartilhado dos sheets do composer.

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        sheetPresentationChrome(sheetScrollBody)
    }
}

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
            Text("NOVO DESDE ÚLTIMA VISITA")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("novo desde a última visita")
        .accessibilityAddTraits([.isStaticText, .isHeader])
    }
}

enum ConversationOutlineA11y {
    static func spokenSheetLabel(turnCount: Int) -> String {
        guard turnCount > 0 else { return spokenEmptySheet() }
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }
}

extension ConversationOutlineSheet {
    func outlineA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.conversationOutlineSheet)
            .accessibilityLabel(ConversationOutlineA11y.spokenSheetLabel(turnCount: bubbles.count))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: bubbles.map(\.id))
    }
}

extension ConversationOutlineA11y {
    static func spokenSnippet(from text: String) -> String {
        ConversationOutlineA11ySnippet.spokenSnippet(from: text)
    }
}

extension ConversationOutlineA11y {
    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }
}

extension ConversationOutlineA11y {
    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        ConversationOutlineA11ySnippet.spokenRow(index: index, role: role, snippet: snippet)
    }
}

enum ConversationOutlineA11ySnippet {
    static func spokenSnippet(from text: String) -> String {
        let trimmed = AtlasMarkdown.plainText(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "sem texto visível neste turno"
        }
        return String(trimmed.prefix(140))
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        "turno \(index), \(ConversationOutlineA11y.spokenRole(role)), \(snippet)"
    }
}

extension ConversationOutlineSheet {
    @ViewBuilder
    var outlineRowList: some View {
        ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
            ConversationOutlineRow(index: index + 1, bubble: bubble, reduceMotion: reduceMotion)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}

// MARK: - Índice da conversa

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        outlineA11yBind(
            SheetShell(title: "Índice da conversa") {
                if bubbles.isEmpty {
                    outlineEmpty
                } else {
                    outlineRowList
                }
            }
        )
    }
}

extension ConversationOutlineSheet {
    var outlineEmpty: some View {
        Text("Nenhum turno carregado nesta thread.")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .accessibilityLabel(ConversationOutlineA11y.spokenEmptySheet())
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(A11yID.conversationOutlineEmpty)
    }
}

extension ConversationOutlineRow {
    var snippet: String {
        ConversationOutlineA11y.spokenSnippet(from: bubble.text)
    }

    var outlineLead: some View {
        outlineLeadMeta
    }
}

extension ConversationOutlineRow {
    var outlineLeadIndex: some View {
        Text(String(format: "%02d", index))
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.accent)
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}

extension ConversationOutlineRow {
    var outlineLeadSnippetStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            outlineLeadRole
            Text(snippet)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}

extension ConversationOutlineRow {
    var outlineLeadMeta: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            outlineLeadIndex
            outlineLeadSnippetStack
            Spacer(minLength: 0)
        }
    }
}

extension ConversationOutlineRow {
    var outlineLeadRole: some View {
        Text(bubble.role == "user" ? "Você" : "Atlas")
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    var body: some View {
        outlineLead
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 10)
            .frame(minHeight: 48, alignment: .center)
            .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                ConversationOutlineA11y.spokenRow(index: index, role: bubble.role, snippet: snippet)
            )
    }
}

extension ConversationHandoffReceipt {
    var accessibilitySummary: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment.map { ", há \($0)" } ?? ""
        if isReady {
            return "continuidade pronta no \(dest), mesma thread \(thread), sem prompt duplicado\(age)"
        }
        if isPending {
            return "continuidade enviando para o \(dest), mesma thread \(thread)\(age)"
        }
        return "recibo de continuidade para \(dest), \(atlasHandoffStatusEditorial(handoff.status)), thread \(thread)\(age)"
    }
}

extension ConversationHandoffReceipt {
    var handoffAgeFragment: String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date)
    }
}

extension ConversationHandoffReceipt {
    var headline: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        if isReady { return "Pronto no \(dest)" }
        if isPending { return "Enviando para o \(dest)…" }
        return "Continuidade para \(dest)"
    }
}

extension ConversationHandoffReceipt {
    var receiptCopy: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(headline)
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subline)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}

extension ConversationHandoffReceipt {
    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .atlasSans(12, .semibold)
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .modifier(ReceiptSpinEffect(active: isPending && !reduceMotion))
            .accessibilityHidden(true)
    }
}

// iOS 17 compat: `.symbolEffect(.rotate,…)` exige iOS 18. Rotação contínua
// própria (deploymentTarget = iOS 17), respeitando Reduce Motion via `active`.
private struct ReceiptSpinEffect: ViewModifier {
    let active: Bool
    @State private var spinning = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active && spinning ? 360 : 0))
            .animation(active ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                       value: spinning)
            .onAppear { if active { spinning = true } }
            .onChange(of: active) { _, now in spinning = now }
    }
}

extension ConversationHandoffReceipt {
    var receiptRowHBox: some View {
        HStack(spacing: 9) {
            receiptRowLeading
            Spacer(minLength: 0)
        }
    }
}

extension ConversationHandoffReceipt {
    var receiptRowLayout: some View {
        receiptRowHBox
    }
}

extension ConversationHandoffReceipt {
    @ViewBuilder
    var receiptRowLeading: some View {
        receiptIcon
        receiptCopy
    }
}

extension ConversationHandoffReceipt {
    var receiptRowStack: some View {
        receiptRowLayout
    }
}

extension ConversationHandoffReceipt {
    func pendingSubline(route: String, thread: String, age: String?) -> String {
        var parts = [atlasHandoffStatusEditorial(handoff.status), route, "thread \(thread)"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}

extension ConversationHandoffReceipt {
    func readySubline(route: String, thread: String, age: String?) -> String {
        var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}

extension ConversationHandoffReceipt {
    var subline: String {
        let route = "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment
        if isReady { return readySubline(route: route, thread: thread, age: age) }
        return pendingSubline(route: route, thread: thread, age: age)
    }
}

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isReady: Bool { handoff.status == "ready" }
    var isPending: Bool { handoff.status == "pending" }

    var body: some View {
        receiptChrome(receiptRowStack)
    }
}

extension ConversationHandoffReceipt {
    func receiptChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 44, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .fill(AtlasTheme.goldVeil)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .stroke(AtlasTheme.goldBorder, lineWidth: 1)
            )
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 2)
            .padding(.bottom, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilitySummary)
            // Ready = landmark; pending live = updatesFrequently (respect Reduce Motion).
            .accessibilityAddTraits(handoffAccessibilityTraits)
            .accessibilityIdentifier(A11yID.continuityHandoffReceipt)
    }

    var handoffAccessibilityTraits: AccessibilityTraits {
        if isReady { return [.isStaticText, .isHeader] }
        if isPending && !reduceMotion { return [.isStaticText, .updatesFrequently] }
        return .isStaticText
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealBody(now: Date) -> some View {
        sealChrome(now: now)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(StaleReadSealA11y.spokenLabel(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
    }
}

extension StaleReadSeal {
    func sealCaptionRow(now: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(StaleReadSealA11y.displayCaption(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
            .font(AtlasFont.mono(11))
            .modifier(NumericTextTransition(enabled: !reduceMotion && !confirming))
            .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealChrome(now: Date) -> some View {
        sealCaptionRow(now: now)
            .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
            .padding(.vertical, 2)
            .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
            .opacity(confirming && !reduceMotion ? 0.72 : 1)
            .animation(confirming && !reduceMotion ? .easeInOut(duration: 0.32) : nil, value: confirming)
    }
}

enum StaleReadSealA11y {
    static func spokenLabel(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion
                ? "histórico salvo atualizado"
                : "histórico salvo atualizado após sincronizar"
        }
        return "histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }
}

extension StaleReadSealA11y {
    static func displayCaption(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion ? "leitura atualizada" : "leitura sincronizada"
        }
        return "visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealTimelineGate(now: Date) -> some View {
        if reduceMotion || confirming {
            sealBody(now: now)
        } else {
            TimelineView(.periodic(from: Date(), by: 60)) { context in
                sealBody(now: context.date)
            }
        }
    }
}

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        sealTimelineGate(now: Date())
            .accessibilityIdentifier(A11yID.conversationStaleReadSeal)
            .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }
}

// Receipt/seals: ConversationChromeSheets+Receipt.swift

extension ComposerAttachmentsSheet {
    var attachmentsSheetChrome: some View {
        SheetShell(title: "Adicionar") {
            attachmentOptions
        }
        .accessibilityIdentifier(A11yID.attachmentsSheet)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenSheet)
        .accessibilityHint(ComposerAttachmentsA11y.spokenSheetHint)
        .onChange(of: pickedPhoto) { _, photo in
            if photo != nil {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                dismiss()
            }
        }
    }
}

extension ComposerAttachmentsSheet {
    var pasteboardText: String? {
        UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
    }

    @ViewBuilder var attachmentOptions: some View {
        attachmentPhotoOptions
        attachmentFileAndPaste
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonA11y<V: View>(_ button: V) -> some View {
        button
            .disabled(pasteboardText == nil)
            .accessibilityLabel(ComposerAttachmentsA11y.spokenPaste(hasText: pasteboardText != nil))
            .accessibilityHint(pasteboardText == nil
                ? ComposerAttachmentsA11y.spokenPasteDisabledHint
                : ComposerAttachmentsA11y.spokenPasteHint)
            .accessibilityIdentifier(A11yID.attachmentPaste)
            .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonAction() {
        guard let text = pasteboardText else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in onPaste(text) }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileOption: some View {
        Button { choose(onChooseFile) } label: {
            ComposerAttachmentRow(icon: "doc", title: "Arquivo", subtitle: "PDF, texto, código ou dados")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenFile)
        .accessibilityHint(ComposerAttachmentsA11y.spokenFileHint)
        .accessibilityIdentifier(A11yID.attachmentFile)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileAndPaste: some View {
        attachmentFileOption
        pasteButton
    }

    func choose(_ action: @escaping @MainActor () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in action() }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var pasteButton: some View {
        pasteButtonA11y(
            Button {
                pasteButtonAction()
            } label: {
                pasteButtonLabel
            }
            .buttonStyle(.plain)
        )
    }
}

extension ComposerAttachmentsSheet {
    var pasteButtonLabel: some View {
        ComposerAttachmentRow(
            icon: "doc.on.clipboard",
            title: "Colar contexto",
            subtitle: pasteboardText == nil
                ? "Nada na área de transferência"
                : "Adicionar texto da área de transferência"
        )
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentCameraOption: some View {
        Button { choose(onChooseCamera) } label: {
            ComposerAttachmentRow(icon: "camera", title: "Câmera", subtitle: "Capturar agora")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(CameraPickerA11y.spokenChooseCamera)
        .accessibilityHint(CameraPickerA11y.spokenChooseCameraHint)
        .accessibilityIdentifier(A11yID.cameraPicker)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOption: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            ComposerAttachmentRow(icon: "photo", title: "Foto", subtitle: "Escolher da biblioteca")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenPhoto)
        .accessibilityHint(ComposerAttachmentsA11y.spokenPhotoHint)
        .accessibilityIdentifier(A11yID.attachmentPhoto)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOptions: some View {
        attachmentPhotoOption
        attachmentCameraOption
    }
}

// Revelação progressiva do composer: foto, arquivo, câmera e contexto colado.
struct ComposerAttachmentsSheet: View {
    @Binding var pickedPhoto: PhotosPickerItem?
    let onChooseFile: @MainActor () -> Void
    let onChooseCamera: @MainActor () -> Void
    let onPaste: @MainActor (String) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        attachmentsSheetChrome
    }
}

extension ComposerAttachmentRow {
    var attachmentRowIcon: some View {
        Image(systemName: icon)
            .atlasSans(17, .medium)
            .foregroundStyle(AtlasTheme.accent)
            .frame(width: 28)
            .accessibilityHidden(true)
    }
}

extension ComposerAttachmentRow {
    var attachmentRowTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle).atlasSans(13).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension ComposerAttachmentRow {
    var attachmentRowCopy: some View {
        HStack(spacing: 14) {
            attachmentRowIcon
            attachmentRowTextStack
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .frame(minHeight: 56)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        attachmentRowCopy
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title), \(subtitle)")
    }
}

enum ComposerSheetA11y {}

extension ComposerSheetA11y {
    static let modeSheetHint = "escolhe um rótulo local; não altera o turno ainda"
    static let effortSheetHint = "escolhe o esforço computacional do próximo envio"
    static let workspaceSheetHint = "escolhe a pasta do próximo envio entre as conversas carregadas"
}

extension ComposerSheetA11y {
    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"

    static func modeLabel(_ key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }
}

extension ComposerSheetA11y {
    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"
}

extension ModeSheet {
    var modeFootnote: some View {
        Text(ComposerSheetA11y.modeFootnote)
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

extension ModeSheet {
    var modeRows: some View {
        ForEach(Self.modes, id: \.0) { key, label in
            let isSelected = key == selected
            SheetRow(
                label: label,
                sub: ComposerSheetA11y.modeFootnote,
                selected: isSelected,
                accessibilityLabel: ComposerSheetA11y.modeLabel(key, title: label, selected: isSelected),
                accessibilityIdentifier: A11yID.modeRow(key)
            ) {
                // Soft owned by SheetRow — avoid double fire.
                selected = key
                dismiss()
            }
        }
    }
}

extension ModeSheet {
    static let modes = [
        ("geral", "Geral"),
        ("operacional", "Operacional"),
        ("autônomos", "Autônomos"),
        ("programação", "Programação"),
    ]
}

struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                workspaceEmptyLabel
            } else {
                workspaceList
            }
        }
        .accessibilityIdentifier(A11yID.workspaceSheet)
        .accessibilityLabel("workspace da conversa")
        .accessibilityHint(ComposerSheetA11y.workspaceSheetHint)
    }
}

extension WorkspaceSheet {
    var workspaceEmptyLabel: some View {
        Text("Nenhum workspace nas conversas carregadas")
            .atlasSans(15)
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .accessibilityLabel(ComposerSheetA11y.workspaceEmpty)
    }
}

extension WorkspaceSheet {
    var workspaceListHeader: some View {
        Text("pastas das conversas carregadas · vale no próximo envio")
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityAddTraits(.isHeader)
    }

    func workspaceCountLine(_ count: Int) -> String {
        count == 1 ? "1 conversa carregada" : "\(count) conversas carregadas"
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    var workspaceList: some View {
        workspaceListHeader
        ForEach(workspaces) { ws in
            workspaceRow(ws)
        }
    }
}

extension WorkspaceSheet {
    func workspaceRowPick(_ ws: Workspace) {
        // Soft owned by SheetRow — avoid double fire.
        onPick(ws)
        dismiss()
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRowBuild(_ ws: Workspace, isSelected: Bool) -> some View {
        SheetRow(
            label: ws.name,
            sub: workspaceCountLine(ws.count),
            selected: isSelected,
            accessibilityLabel: ComposerSheetA11y.workspaceLabel(
                name: ws.name, count: ws.count, selected: isSelected
            ),
            accessibilityIdentifier: A11yID.workspaceRow(ws.id)
        ) {
            workspaceRowPick(ws)
        }
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRow(_ ws: Workspace) -> some View {
        workspaceRowBuild(ws, isSelected: ws.name == current)
    }
}

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) var dismiss  // interno: peels em outros arquivos usam
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Modo") {
            modeFootnote
            modeRows
        }
        .accessibilityIdentifier(A11yID.modeSheet)
        .accessibilityLabel("modo da conversa")
        .accessibilityHint(ComposerSheetA11y.modeSheetHint)
    }
}

extension ComposerSheetA11y {
    static func effortLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenEffort(effort)), \(state)"
    }
}

extension ComposerSheetA11y {
    static func spokenEffortLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "esforço automático"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        default: return nil
        }
    }
}

extension ComposerSheetA11y {
    static func spokenEffort(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLight(effort) { return light }
        switch effort {
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        default: return "esforço automático"
        }
    }
}

extension ComposerSheetA11y {
    static func effortSubtitleLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        default: return nil
        }
    }
}

extension ComposerSheetA11y {
    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        if let light = effortSubtitleLight(effort) { return light }
        switch effort {
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        default: return "Atlas Decide escolhe; nada vai no payload"
        }
    }
}

extension EffortSheet {
    func effortA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.effortSheet)
            .accessibilityLabel("esforço computacional")
            .accessibilityHint(ComposerSheetA11y.effortSheetHint)
    }
}

extension EffortSheet {
    var effortFootnoteCopy: some View {
        Text("vale para o próximo envio; automático deixa o Atlas Decide escolher")
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

extension EffortSheet {
    func pick(_ effort: AtlasComputeEffort) {
        // Persistência é do MODEL (boundary): a View nunca toca storage.
        // Soft owned by SheetRow — avoid double fire.
        model.setEffort(effort)
        dismiss()
    }
}

extension EffortSheet {
    var effortRows: some View {
        ForEach(AtlasComputeEffort.allCases, id: \.self) { effort in
            let selected = effort == model.effort
            SheetRow(
                label: effort.shortLabel.capitalized,
                sub: ComposerSheetA11y.effortSubtitle(effort),
                selected: selected,
                accessibilityLabel: ComposerSheetA11y.effortLabel(effort, selected: selected),
                accessibilityIdentifier: A11yID.effortRow(effort.rawValue)
            ) {
                pick(effort)
            }
        }
    }
}

extension EffortSheet {
    @ViewBuilder
    var effortSheetContent: some View {
        effortFootnoteCopy
        effortRows
    }
}

struct EffortSheet: View {
    var model: ConversationModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        effortA11yBind(
            SheetShell(title: "Esforço") {
                effortSheetContent
            }
        )
    }
}

struct SheetRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let label: String
    var sub: String? = nil
    let selected: Bool
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    var body: some View {
        sheetRowA11y
    }
}

extension SheetRow {
    var sheetRowA11y: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            rowLabel
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            accessibilityLabel ?? SheetShellA11y.spokenRow(label: label, sub: sub, selected: selected)
        )
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
        .modifier(OptionalAccessibilityIdentifier(id: accessibilityIdentifier))
        .overlay(alignment: .bottom) { sheetRowDivider }
    }
}

extension SheetRow {
    var sheetRowDivider: some View {
        Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
    }
}

extension SheetRow {
    var sheetRowLeading: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if let sub {
                Text(sub).atlasSans(13).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension SheetRow {
    @ViewBuilder
    var sheetRowTrailing: some View {
        if selected {
            Image(systemName: "checkmark").atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
        }
    }
}

extension SheetRow {
    var rowLabel: some View {
        HStack(spacing: 12) {
            sheetRowLeading
            Spacer()
            sheetRowTrailing
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }
}


// Cycle 044 fuse → AtlasCloseToolbarButton.swift

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
        // Dispensar nunca é acento: Fechar/Cancelar fala ink neutro (canon §C).
        .tint(AtlasTheme.textSecondary)
        .accessibilityLabel(spokenLabel)
        .accessibilityHint(spokenHint)
        .accessibilityAddTraits(.isButton)
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
