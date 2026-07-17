import SwiftUI
import AtlasCore

// MARK: - Paleta do domínio (gramática de estado)
// FileRow → AtlasCodeFileRow.swift · Chip → AtlasCodeChipRow.swift
// RelativeTime → AtlasCodeRelativeTime.swift
// Color → AtlasCodePalette+Color.swift

enum AtlasCodePalette {
    static let onMain = AtlasTheme.accent
    static let alert = Color(hex: 0xE08C8C)
    static let healed = Color(hex: 0x83B46D)
    static let history = Color(hex: 0x647682)
}
