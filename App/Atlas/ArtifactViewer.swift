import SwiftUI
import UIKit
import AtlasCore

// Preview helpers do ArtifactSheet — fora do shell para a régua (~160).
// Preview → ArtifactViewer+Preview.swift
// Ficha → ArtifactFileFicha.swift

enum ArtifactViewer {
    static func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        switch kind {
        case .image: "imagem"
        case .markdown: "markdown"
        case .text: "texto"
        case .diff: "diff"
        case .file: "arquivo"
        }
    }

    static func byteLabel(_ bytes: Int) -> String {
        if bytes < 1_024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(max(1, bytes / 1_024)) KB" }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
    }
}
