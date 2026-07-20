import SwiftUI
import AtlasCore

// Spine — peels no ✦ PAI (mais antigo = abaixo na lista).
// Newest-first: tip acima, origem abaixo. Zero C flutuante, zero faixa cinza extra.

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumnConnectors(spineTint: Color, motion: Animation?) -> some View {
        let lane = AtlasCodeGraphLane.index(for: state)
        let above = AtlasCodeGraphLane.index(for: aboveState ?? .onMain)
        let below = AtlasCodeGraphLane.index(for: belowState ?? .onMain)
        let trunkX = AtlasCodeGraphLane.base
        let sideX = AtlasCodeGraphLane.sideX
        let laneX = AtlasCodeGraphLane.x(lane: lane)
        let nodeY = AtlasCodeGraphLane.nodeCenterY

        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                let h = max(size.height, nodeY + 12)
                strokeTrunk(context: context, trunkX: trunkX, nodeY: nodeY, h: h)

                // Origem: este ✦ é o pai — faixa está ACIMA (tip/cadeia mais nova).
                if lane == 0, above > 0, !isFirst {
                    let peel = AtlasCodeGraphLane.forkPath(
                        from: CGPoint(x: trunkX, y: nodeY),
                        to: CGPoint(x: sideX, y: 0)
                    )
                    context.stroke(
                        peel,
                        with: .color(peelColorTowardAbove.opacity(0.92)),
                        lineWidth: AtlasCodeGraphLane.sideWidth
                    )
                }

                guard lane > 0 else { return }

                let stroke = sideStrokeColor

                // Chega de cima (cadeia na mesma faixa).
                if above > 0, !isFirst {
                    var up = Path()
                    up.move(to: CGPoint(x: sideX, y: 0))
                    up.addLine(to: CGPoint(x: sideX, y: nodeY))
                    context.stroke(up, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                }

                // Chega de baixo (peel do pai na linha de baixo → nosso rodapé).
                if below == 0, !isLast {
                    var fromParent = Path()
                    fromParent.move(to: CGPoint(x: sideX, y: h))
                    fromParent.addLine(to: CGPoint(x: sideX, y: nodeY))
                    context.stroke(fromParent, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                } else if below > 0, !isLast {
                    var down = Path()
                    down.move(to: CGPoint(x: sideX, y: nodeY))
                    down.addLine(to: CGPoint(x: sideX, y: h))
                    context.stroke(down, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                } else if isLast {
                    // Sem pai na lista: elbow no próprio tip (única âncora possível).
                    let elbow = AtlasCodeGraphLane.forkPath(
                        from: CGPoint(x: trunkX, y: nodeY),
                        to: CGPoint(x: sideX, y: nodeY)
                    )
                    context.stroke(elbow, with: .color(stroke), lineWidth: AtlasCodeGraphLane.sideWidth)
                }
            }
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Color.clear.frame(height: max(0, nodeY - 11))
                HStack(spacing: 0) {
                    Color.clear.frame(width: max(0, laneX - 11))
                    spineNode(motion: motion)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func strokeTrunk(
        context: GraphicsContext,
        trunkX: CGFloat,
        nodeY: CGFloat,
        h: CGFloat
    ) {
        var trunk = Path()
        let top: CGFloat = isFirst ? nodeY : 0
        let bot: CGFloat = isLast ? nodeY : h
        guard bot > top else { return }
        trunk.move(to: CGPoint(x: trunkX, y: top))
        trunk.addLine(to: CGPoint(x: trunkX, y: bot))
        context.stroke(
            trunk,
            with: .color(AtlasTheme.accent.opacity(0.42)),
            lineWidth: AtlasCodeGraphLane.trunkWidth
        )
    }

    private var sideStrokeColor: Color {
        color.opacity(state == .history ? 0.5 : 0.92)
    }

    private var peelColorTowardAbove: Color {
        guard let aboveState else { return AtlasCodePalette.alert }
        return AtlasCodePalette.color(for: aboveState)
    }
}
