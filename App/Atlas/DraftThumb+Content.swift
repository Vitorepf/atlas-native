import SwiftUI
import UIKit
import AtlasCore

// Thumb content chrome — peel de DraftThumb.
// Frame → DraftThumb+Content+Frame.swift
// A11y → DraftThumb+Content+A11y.swift

extension DraftThumb {
    var thumbContent: some View {
        thumbContentA11y(thumbFrame)
    }
}
