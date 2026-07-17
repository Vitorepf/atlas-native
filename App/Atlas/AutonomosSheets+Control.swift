import SwiftUI
import AtlasCore

extension AtlasAutonomosStartRunMode {
    var actionLabel: String { self == .execute ? "Executar de verdade" : "Novo ciclo · ensaio" }
}

struct AutonomosControlSheet: View {
    let action: AtlasAutonomosRunAction
    let onConfirm: (String, String) -> Void

    var body: some View {
        AutonomosReasonSheet(title: label, explainer: "Ação governada — operador e motivo ficam no recibo auditável.", onConfirm: onConfirm)
    }
}
