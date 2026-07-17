import AtlasCore
import SwiftUI

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
/// Rules → AtlasCodeMirrorCard+Rules.swift
/// Header → AtlasCodeMirrorCard+Header.swift
/// Chrome → AtlasCodeMirrorCard+CardChrome.swift
struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        mirrorCardChrome
    }
}
