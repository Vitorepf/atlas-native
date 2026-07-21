import AtlasCore
import SwiftUI

// Cycle 039 fuse → ArenaSuiteSheet.swift

// MARK: - Arena suite sheet

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}
