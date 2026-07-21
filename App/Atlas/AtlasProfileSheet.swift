import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

// --- AtlasProfileSheet.swift ---
struct AtlasProfileSheet: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    profileMasthead
                    profileRows
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 18)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .atlasSans(15, .medium)
                        .tint(AtlasTheme.textSecondary)
                }
            }
            .accessibilityIdentifier(A11yID.profileSheet)
        }
    }

    private var profileMasthead: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.fill")
                .atlasSans(26)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 72, height: 72)
                .atlasGlassCircle()
                .accessibilityHidden(true)
            Text("Vitor")
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("operador do Atlas")
                .atlasSans(13)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Vitor, operador do Atlas")
    }
}

// --- AtlasProfileSheet+Rows.swift ---
extension AtlasProfileSheet {
    @ViewBuilder
    var profileRows: some View {
        @Bindable var session = session

        VStack(spacing: 0) {
            profileLine("Servidor", value: session.host, mono: true)
            Divider().overlay(AtlasTheme.separatorSoft)
            profileLine("Estado", value: connectionLabel)
            Divider().overlay(AtlasTheme.separatorSoft)
            profileLine("Conversas", value: "\(session.threads.count)")
            Divider().overlay(AtlasTheme.separatorSoft)
            profileLine("Workspaces", value: "\(session.workspaces.count)")
        }
        .atlasCard()

        Toggle(isOn: $session.auditModeEnabled) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Modo auditoria").atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("mostra detalhes técnicos nas telas")
                    .atlasSans(12).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .tint(AtlasTheme.accent)
        .padding(.horizontal, 14).padding(.vertical, 12)
        .atlasCard()
        .accessibilityIdentifier(A11yID.profileAuditToggle)

        Text("Atlas \(appVersion)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.top, 8)
    }

    private func profileLine(_ label: String, value: String, mono: Bool = false) -> some View {
        HStack {
            Text(label).atlasSans(15).foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
            if mono {
                Text(value).font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            } else {
                Text(value).atlasSans(15)
                    .foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }

    var connectionLabel: String {
        if session.failureKind != nil { return "fora de alcance" }
        if case .loaded = session.phase { return "conectado" }
        return "conectando…"
    }

    var appVersion: String {
        let info = Bundle.main.infoDictionary ?? [:]
        let v = info["CFBundleShortVersionString"] as? String ?? "?"
        let b = info["CFBundleVersion"] as? String ?? "?"
        return "\(v) (\(b))"
    }
}
