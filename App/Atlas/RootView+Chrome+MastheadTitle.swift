import SwiftUI

// Masthead title stack — peel de RootView+Chrome+Masthead.
// BrandRow → RootView+Chrome+MastheadTitle+BrandRow.swift
// AccentRule → RootView+Chrome+MastheadTitle+AccentRule.swift

extension RootView {
  var mastheadTitleStack: some View {
    VStack(spacing: 5) {
      mastheadBrandRow
      mastheadAccentRule
      mastheadAuditBadge
    }
  }
}
