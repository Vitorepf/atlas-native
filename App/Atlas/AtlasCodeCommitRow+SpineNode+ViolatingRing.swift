import SwiftUI
import AtlasCore

// Violating ring — morto. Exceção = geometria de lane + disco, não anel no tronco.
// (GitKraken: bola na faixa lateral; o anel no tronco lia como "bug na linha".)

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineViolatingRing(motion: Animation?) -> some View {
        EmptyView()
    }
}
