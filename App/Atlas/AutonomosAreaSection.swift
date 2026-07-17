import SwiftUI
import AtlasCore

/// Lista de instâncias (áreas) — seleção dispara `selectArea` no model.
struct AutonomosAreaPicker: View {
    let areas: [AtlasAutonomosArea]
    let selectedAreaID: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("INSTÂNCIAS")
            ForEach(areas) { area in
                Button {
                    onSelect(area.id)
                } label: {
                    HStack(spacing: 10) {
                        Circle().fill(areaStateColor(area)).frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(area.areaName).font(.system(.footnote, weight: .semibold))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Text(area.objective).font(.caption).foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(areaStateLabel(area)).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(area.id == selectedAreaID ? AtlasTheme.surfaceHi : AtlasTheme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(area.id == selectedAreaID ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // C13: fase canônica do Core (terminated > paused > running > idle) —
    // a View não relê nem reinterpreta run_state cru.
    private func areaStateLabel(_ area: AtlasAutonomosArea) -> String {
        switch area.loopStatus.phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }

    private func areaStateColor(_ area: AtlasAutonomosArea) -> Color {
        switch area.loopStatus.phase {
        case .terminated: return AtlasTheme.domOperacional
        case .paused: return AtlasTheme.accent
        case .running: return AtlasTheme.domAutonomos
        case .idle: return AtlasTheme.textTertiary
        }
    }
}

/// C13: disponibilidade vem de canControlSelectedArea (POSTs existem e são
/// governados) — nunca de live.readOnly, que descreve apenas o GET.
struct AutonomosAreaControls: View {
    let areaName: String
    let isPaused: Bool
    let canControl: Bool
    let onResume: () -> Void
    let onPause: () -> Void
    let onTransfer: () -> Void
    let onKill: () -> Void
    let onDryRun: () -> Void
    let onExecute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if isPaused {
                    Button("Retomar", action: onResume).buttonStyle(AutonomosPrimaryButtonStyle())
                } else {
                    Button("Pausar", action: onPause).buttonStyle(AutonomosSecondaryButtonStyle())
                }
                Button("Transferir", action: onTransfer).buttonStyle(AutonomosSecondaryButtonStyle())
                Button("Encerrar", action: onKill).buttonStyle(AutonomosDestructiveButtonStyle())
            }
            HStack(spacing: 8) {
                Button("Novo ciclo · ensaio", action: onDryRun)
                    .buttonStyle(AutonomosPrimaryButtonStyle())
                Button("Executar de verdade", action: onExecute)
                    .buttonStyle(AutonomosSecondaryButtonStyle())
            }
        }
        .disabled(!canControl)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenContainerLabel)
        .accessibilityHint(spokenContainerHint)
        .accessibilityIdentifier(A11yID.autonomosAreaControls)
    }
}
