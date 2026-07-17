import SwiftUI

// Masthead overlay — peel de RootView+Chrome.
// Audit → RootView+Chrome+MastheadAudit.swift
// Title → RootView+Chrome+MastheadTitle.swift

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
