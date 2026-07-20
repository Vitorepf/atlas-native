import SwiftUI
import AtlasCore

/// Shell Autônomos v9 — catálogo do operador → hub → evolução · pílula · Novo.
struct AutonomosMapShell: View {
    @Environment(AtlasSession.self) private var session
    let model: AutonomosModel
    @Binding var destination: AutonomosDestination?
    @Binding var selectedUnitID: String?
    @Binding var showNewSheet: Bool
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var confirmEnd = false

    private var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    private var vestmentForAsk: AutonomosHubVestment {
        guard let unit = selectedUnit else { return .quiet }
        return unit.paused ? .quiet : .live
    }

    var body: some View {
        Group {
            if let destination {
                route(destination)
            } else {
                AutonomosListView(
                    units: model.operatorUnits,
                    onOpen: { unit in
                        selectedUnitID = unit.id
                        destination = .hub
                    },
                    onCreate: { showNewSheet = true }
                )
            }
        }
        .sheet(isPresented: $showNewSheet) {
            AutonomosNewSheet(
                onCreate: { name, charter in
                    let unit = model.createOperatorUnit(name: name, charter: charter)
                    showNewSheet = false
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCancel: { showNewSheet = false }
            )
        }
        .confirmationDialog("Encerrar este Autônomo?", isPresented: $confirmEnd, titleVisibility: .visible) {
            Button("Encerrar de vez", role: .destructive) { deleteSelected() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Sai da sua lista. O motor no servidor ainda não liga a isto.")
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            askPillDock
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
    }

    @ViewBuilder
    private func route(_ destination: AutonomosDestination) -> some View {
        switch destination {
        case .hub:
            if let unit = selectedUnit {
                AutonomosHubView(
                    unit: unit,
                    onNavigate: { self.destination = $0 },
                    onPause: { model.setOperatorUnitPaused(id: unit.id, paused: true) },
                    onResume: { model.setOperatorUnitPaused(id: unit.id, paused: false) },
                    onEnd: { confirmEnd = true }
                )
            } else {
                missingUnit
            }
        case .evolution:
            AutonomosEvolutionView(unit: selectedUnit)
        case .decisions, .decisionInbox, .decisionOrder, .moment, .incident:
            VStack(alignment: .leading, spacing: 12) {
                AutonomosMapChrome.heroTitle("Ainda no escopo local", size: 26)
                Text("Decisões e momentos do motor chegam quando o create no Server existir.")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(AtlasTheme.Space.screen)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var missingUnit: some View {
        VStack(alignment: .leading, spacing: 12) {
            AutonomosMapChrome.heroTitle("Autônomo ausente", size: 26)
            Text("Volte à lista e abra de novo.")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func deleteSelected() {
        guard let id = selectedUnitID else { return }
        model.removeOperatorUnit(id: id)
        selectedUnitID = nil
        destination = nil
    }

    private var askPillDock: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)
            ArenaPremiumAskPill(
                invite: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk)
            ) {
                showingAsk = true
            }
            .accessibilityIdentifier(A11yID.autonomosAskPill)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
        }
        .background(AtlasTheme.bg.opacity(0.01))
    }

    private var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: selectedUnit?.name ?? "Autônomos",
            emptyPrompt: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk),
            emptySuggestions: AutonomosAskContext.emptySuggestions(destination: destination),
            taskKind: "autonomos",
            workspace: nil,
            draft: "",
            turnFacts: { [selectedUnit, destination] _ in
                AutonomosAskContext.facts(unit: selectedUnit, destination: destination)
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AtlasTheme.bg)
        .presentationCornerRadius(28)
    }
}
