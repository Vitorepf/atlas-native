import SwiftUI
import UIKit
import AtlasCore

// Sheet chrome — peel de ArtifactSheet.
// Toolbar → ArtifactSheet+Chrome+Toolbar.swift
// A11y → ArtifactSheet+Chrome+A11y.swift

extension ArtifactSheet {
    func artifactSheetChrome<Content: View>(_ content: Content) -> some View {
        artifactSheetA11y(artifactSheetToolbar(content))
    }
}
