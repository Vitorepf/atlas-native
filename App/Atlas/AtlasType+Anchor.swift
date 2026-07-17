import SwiftUI

// Dynamic Type anchors — peel de AtlasType.

extension AtlasFont {
    static func anchor(_ size: CGFloat) -> Font.TextStyle {
        switch size {
        case 28...: return .largeTitle
        case 22..<28: return .title2
        case 17..<22: return .body
        case 14..<17: return .callout
        case 12..<14: return .footnote
        default: return .caption2
        }
    }
}
