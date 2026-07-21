import SwiftUI
import AtlasCore

// IDLE-COMPRESS body

// --- AtlasCodeFileRow+A11y.swift ---
enum AtlasCodeFileRowA11y {
    static func spokenFile(_ file: AtlasCodeFileChange) -> String {
        var parts = [file.path, verb(for: file.status)]
        if let from = file.renamedFrom { parts.append("de \(from)") }
        if let additions = file.additions, let deletions = file.deletions {
            parts.append("\(additions) linhas adicionadas")
            parts.append("\(deletions) removidas")
        } else {
            parts.append("arquivo binário")
        }
        return parts.joined(separator: ", ")
    }
}

// --- AtlasCodeFileRow+A11yVerb+Mutate.swift ---
extension AtlasCodeFileRowA11y {
    static func verbMutate(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        default: return nil
        }
    }
}

// --- AtlasCodeFileRow+A11yVerb+Transform+RenameCopy.swift ---
extension AtlasCodeFileRowA11y {
    static func verbRenameCopy(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        default: return nil
        }
    }
}

// --- AtlasCodeFileRow+A11yVerb+Transform.swift ---
extension AtlasCodeFileRowA11y {
    static func verbTransform(for status: AtlasCodeFileStatus) -> String {
        if let rename = verbRenameCopy(for: status) { return rename }
        switch status {
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        default: return verbMutate(for: status) ?? "mudança desconhecida"
        }
    }
}

// --- AtlasCodeFileRow+A11yVerb.swift ---
extension AtlasCodeFileRowA11y {
    static func verb(for status: AtlasCodeFileStatus) -> String {
        verbMutate(for: status) ?? verbTransform(for: status)
    }
}

// --- AtlasCodeFileRow+Lead.swift ---
extension AtlasCodeFileRow {
    var lead: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: symbol)
                .atlasSans(8.5, .bold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 17, height: 17)
                .background(AtlasTheme.surfaceHi, in: RoundedRectangle(cornerRadius: 5))
                .accessibilityHidden(true)

            fileNameStack

            Spacer(minLength: 8)

            diffStats
        }
    }
}

// --- AtlasCodeFileRow+LeadName.swift ---
extension AtlasCodeFileRow {
    var fileNameStack: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(file.fileName)
                .atlasSans(12.5, .medium)
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
            if let subtitle {
                Text(subtitle)
                    .font(AtlasFont.mono(8.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }
        }
        .accessibilityHidden(true)
    }
}

// --- AtlasCodeFileRow+Meta+Subtitle.swift ---
extension AtlasCodeFileRow {
    var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }
}

// --- AtlasCodeFileRow+Meta+Symbol+Mutate.swift ---
extension AtlasCodeFileRow {
    var symbolMutate: String? {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        default: return nil
        }
    }
}

// --- AtlasCodeFileRow+Meta+Symbol+Transform.swift ---
extension AtlasCodeFileRow {
    var symbolTransform: String? {
        switch file.status {
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        default: return nil
        }
    }
}

// --- AtlasCodeFileRow+Meta+Symbol.swift ---
extension AtlasCodeFileRow {
    var symbol: String {
        symbolMutate ?? symbolTransform ?? "questionmark"
    }
}

// --- AtlasCodeFileRow+Stats.swift ---
extension AtlasCodeFileRow {
    @ViewBuilder
    var diffStats: some View {
        if let additions = file.additions, let deletions = file.deletions {
            Text("+\(additions) \u{2212}\(deletions)")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        } else {
            Text("binário")
                .font(AtlasFont.mono(8.5))
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.7))
                .accessibilityHidden(true)
        }
    }
}

