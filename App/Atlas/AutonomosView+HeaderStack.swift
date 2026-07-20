import SwiftUI
import AtlasCore

// Autônomos header stack — lista ← hub ← push · + na lista.

extension AutonomosView {
    var autonomosHeaderStack: some View {
        VStack(spacing: 0) {
            AutonomosViewHeader(
                auditModeEnabled: session.auditModeEnabled,
                canRefresh: false,
                isHealthy: isHeaderHealthy,
                title: headerTitle,
                subtitle: headerSubtitle,
                subtitleLive: headerSubtitleLive,
                trailing: destination == nil ? .create : .none,
                reduceMotion: reduceMotion,
                onBack: {
                    if let destination {
                        self.destination = destination.backTarget
                        if self.destination == nil {
                            selectedUnitID = nil
                        }
                    } else {
                        dismiss()
                    }
                },
                onRefresh: {},
                onCreate: {
                    showNewSheet = true
                }
            )
            autonomosContentAnimated
        }
    }

    private var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    private var headerTitle: String {
        guard let destination else { return "Autônomos" }
        if case .hub = destination {
            return selectedUnit?.name ?? "Autônomo"
        }
        return destination.navTitle
    }

    private var headerSubtitle: String {
        guard let destination, let unit = selectedUnit else { return "" }
        switch destination {
        case .hub:
            return unit.paused ? "Parado" : "Vivo"
        case .evolution:
            return unit.name
        default:
            return ""
        }
    }

    private var headerSubtitleLive: Bool {
        guard let destination, let unit = selectedUnit else { return false }
        switch destination {
        case .hub, .evolution:
            return !unit.paused
        default:
            return false
        }
    }
}
