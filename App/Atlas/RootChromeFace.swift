import SwiftUI
import AtlasCore

// WAVE-015 fused

extension RootView {
    func mastheadSpokenLabel(auditModeEnabled: Bool) -> String {
        auditModeEnabled ? "Atlas, modo auditoria" : "Atlas"
    }

    func mastheadSpokenHint() -> String {
        "pressione e segure para alternar modo auditoria"
    }
}

extension RootView {
  @ViewBuilder
  var mastheadOverlay: some View {
    mastheadTitleStack
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(mastheadSpokenLabel(auditModeEnabled: session.auditModeEnabled))
    .accessibilityHint(mastheadSpokenHint())
    .accessibilityIdentifier(A11yID.auditMasthead)
    .accessibilityAddTraits(.isHeader)
    .onLongPressGesture(minimumDuration: 0.55) {
      AtlasMotion.softImpact(reduceMotion: reduceMotion)
      session.auditModeEnabled.toggle()
    }
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
}

extension RootView {
    @ViewBuilder
    var mastheadAuditBadge: some View {
        if session.auditModeEnabled {
            Text("AUDITORIA")
                .font(AtlasFont.mono(8))
                .tracking(1.0)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
        }
    }
}

extension RootView {
  // A linha premium do site no clímax dela: ouro em fade nas duas pontas.
  var mastheadAccentRule: some View {
    LinearGradient(
      colors: [AtlasTheme.accent.opacity(0), AtlasTheme.accent.opacity(0.7),
               AtlasTheme.accent.opacity(0)],
      startPoint: .leading, endPoint: .trailing
    )
    .frame(width: 44, height: 1.5)
    .accessibilityHidden(true)
  }
}

extension RootView {
  var mastheadBrandRow: some View {
    HStack(spacing: 7) {
      Text("Atlas")
        .font(AtlasFont.serif(23, .semibold))
        .accessibilityHidden(true)
      Text("✦")
        .font(AtlasFont.serif(12, .semibold))
        .foregroundStyle(session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
        .shadow(
          color: (session.auditModeEnabled ? AtlasTheme.domOperacional : AtlasTheme.accent)
            .opacity(0.35),
          radius: 5,
          y: 0
        )
        .accessibilityHidden(true)
    }
    .foregroundStyle(AtlasTheme.textPrimary)
  }
}

extension RootView {
  var mastheadTitleStack: some View {
    VStack(spacing: 5) {
      mastheadBrandRow
      mastheadAccentRule
      mastheadAuditBadge
    }
  }
}

extension RootView {
    var topBarTrailing: some View {
        // Só busca: o "+" saiu — a pílula "Escreva ao Atlas" é o único ponto
        // de partida (abre o picker: sem repositório ou um repo por recência).
        CircleButton(icon: "magnifyingglass") { path.append(Route.search) }
            .keyboardShortcut("k", modifiers: .command)
            .accessibilityLabel(searchSpokenLabel())
            .accessibilityHint("abre busca nas conversas carregadas")
            .accessibilityIdentifier(A11yID.topbarSearch)
    }
}

extension RootView {
  @ViewBuilder
  var topBar: some View {
    HStack(spacing: 12) {
      topBarAvatar
      topBarCodeButton
      Spacer()
      topBarTrailing
    }
    .overlay { mastheadOverlay }
  }
}

extension RootView {
    var topBarAvatar: some View {
        Button {
            showingProfile = true
        } label: {
            Image(systemName: "person.fill")
                .atlasSans(18)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
        }
        .accessibilityIdentifier(A11yID.topbarProfile)
        .accessibilityLabel(WorkspaceThreadJudgment.profileLabel)
        .accessibilityHint(WorkspaceThreadJudgment.profileHint)
        .sheet(isPresented: $showingProfile) { AtlasProfileSheet() }
    }
}

extension RootView {
    var topBarCodeButton: some View {
        // Sem ponto vermelho (ordem 2026-07-18): a exceção fala DENTRO do
        // Código, com palavra — não com pingo no chrome.
        CircleButton(icon: "point.3.connected.trianglepath.dotted") { path.append(Route.code) }
            .accessibilityLabel(RootHomeSections.codeTopBarLabel(hub: codeHub))
            .accessibilityHint("abre radar de repositórios")
            .accessibilityIdentifier(A11yID.topbarCode)
    }
}


extension RootView {
    @ViewBuilder
    func rootConversationRoutes(for route: Route) -> some View {
        switch route {
        case .workspace(_, _), .thread(_, _), .new, .conversas, .search:
            rootConversationDestination(for: route)
        default:
            EmptyView()
        }
    }
}

extension RootView {
    @ViewBuilder
    func rootAutonomosArenaDestination(for route: Route) -> some View {
        switch route {
        case .autonomos:
            AutonomosView()
        case .arena:
            AtlasArenaView(model: session.arena)
        default:
            EmptyView()
        }
    }
}

extension RootView {
    @ViewBuilder
    func rootDomainDestination(for route: Route) -> some View {
        switch route {
        case .autonomos, .arena:
            rootAutonomosArenaDestination(for: route)
        case .code, .codeGraph(_):
            rootCodeDestination(for: route)
        default:
            EmptyView()
        }
    }
}

extension RootView {
    @ViewBuilder
    func rootDestination(for route: Route) -> some View {
        switch route {
        case .workspace(_, _), .thread(_, _), .new, .conversas, .search:
            rootConversationRoutes(for: route)
        case .autonomos, .arena, .code, .codeGraph(_):
            rootDomainDestination(for: route)
        }
    }
}

