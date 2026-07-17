import SwiftUI
import AtlasCore

// Week section — peel de AtlasCodeGraphChrome+Status.
// Heal → AtlasCodeGraphChrome+WeekHeal.swift · Body → +WeekBody.swift

extension AtlasCodeView {
    /// A semana + o recibo da noite: fatos consumados, nunca pedidos.
    var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let week = model.week {
                weekBody(week)
            }
            weekHealReceiptButton
        }
    }
}
