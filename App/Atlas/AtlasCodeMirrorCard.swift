import AtlasCore
import SwiftUI

// Cycle 039 fuse → AtlasCodeMirrorCard.swift

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        mirrorCardChrome
    }
}
