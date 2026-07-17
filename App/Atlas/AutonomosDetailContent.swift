import SwiftUI
import AtlasCore

// Cards de work orders/inbox/findings/budgets — peel de AutonomosDetailSheet.
// Work/inbox → AutonomosDetailWorkRows · Findings/budgets → AutonomosDetailLedgerRows
// Work → AutonomosDetailContent+Work.swift
// Ledger → AutonomosDetailContent+Ledger.swift

enum AutonomosDetailContent {
    @ViewBuilder
    static func rows(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> some View {
        switch kind {
        case .workOrders, .inbox:
            AutonomosDetailContentWork.rows(kind: kind, backlog: backlog)
        case .findings, .budgets:
            AutonomosDetailContentLedger.rows(kind: kind, backlog: backlog)
        }
    }
}
