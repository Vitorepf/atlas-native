import SwiftUI

// Dynamic Type anchors — peel de AtlasType.
// Large → AtlasType+Anchor+Large.swift
// Small → AtlasType+Anchor+Small.swift

extension AtlasFont {
    static func anchor(_ size: CGFloat) -> Font.TextStyle {
        anchorLarge(size) ?? anchorSmall(size)
    }
}
