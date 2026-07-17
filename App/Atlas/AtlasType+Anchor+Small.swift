import SwiftUI

// Small Dynamic Type anchors — peel de AtlasType+Anchor.

extension AtlasFont {
    static func anchorSmall(_ size: CGFloat) -> Font.TextStyle {
        switch size {
        case 14..<17: return .callout
        case 12..<14: return .footnote
        default: return .caption2
        }
    }
}
