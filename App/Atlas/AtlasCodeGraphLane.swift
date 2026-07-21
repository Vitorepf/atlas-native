import SwiftUI
import AtlasCore

// Lanes do grafo — presentation-only.
// Uma faixa de exceção (fora + história): sabe-se DE ONDE saiu (peel no ✦ pai).
// Grid: trunk=24, side=24+36. Curva = midpoint (tangente vertical).

enum AtlasCodeGraphLane {
    static let gutter: CGFloat = 72
    static let base: CGFloat = 24
    static let step: CGFloat = 36
    static let trunkWidth: CGFloat = 2.2
    static let sideWidth: CGFloat = 1.85
    static let nodeRadius: CGFloat = 5.5
    static let nodeCenterY: CGFloat = 22

    /// 0 = trunk. 1 = exceção (violating + history na MESMA faixa — sem linha cinza solta).
    static func index(for state: AtlasCodeNodeState) -> Int {
        switch state {
        case .onMain, .healed: return 0
        case .violating, .history: return 1
        }
    }

    static func x(for state: AtlasCodeNodeState) -> CGFloat {
        base + CGFloat(index(for: state)) * step
    }

    static func x(lane: Int) -> CGFloat {
        base + CGFloat(max(0, lane)) * step
    }

    static var sideX: CGFloat { x(lane: 1) }

    /// Curva GitKraken: tangentes verticais no midpoint Y.
    static func forkPath(from: CGPoint, to: CGPoint) -> Path {
        Path { path in
            let midY = (from.y + to.y) / 2
            path.move(to: from)
            path.addCurve(
                to: to,
                control1: CGPoint(x: from.x, y: midY),
                control2: CGPoint(x: to.x, y: midY)
            )
        }
    }
}
