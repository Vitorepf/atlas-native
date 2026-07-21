import SwiftUI
import AtlasCore

// Masthead — peel de RootView (régua anti-inchaço).
// Code button → RootView+ChromeCodeButton.swift
// Overlay → RootView+Chrome+Masthead.swift · Input pill → RootView+InputBar.swift
// Trailing → RootView+Chrome+Trailing.swift
// Avatar → RootView+ChromeAvatar.swift

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
