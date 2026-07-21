import Foundation

// WAVE-131 A11yID Autonomos domain

extension A11yID {
    static let autonomosScreen = "autonomos-screen"
    static let autonomosAwaitingYou = "autonomos-awaiting-you"
    static let autonomosDetailSheet = "autonomos-detail-sheet"
    static let autonomosDetailButtonPrefix = "autonomos-detail-button-"
    static let autonomosRhythmLine = "autonomos-rhythm-line"
    static let autonomosRhythmSheet = "autonomos-rhythm-sheet"
    static let autonomosGovernedToggle = "autonomos-governed-toggle"
    static let autonomosOperationToggle = "autonomos-operation-toggle"
    static let autonomosRhythmUnmute = "autonomos-rhythm-unmute"
    static let autonomosHub = "autonomos-hub"
    static let autonomosList = "autonomos-list"
    static let autonomosNew = "autonomos-new"
    static let autonomosEvolution = "autonomos-evolution"
    static let autonomosDecisions = "autonomos-decisions"
    static let autonomosDecision = "autonomos-decision"
    static let autonomosAreaMap = "autonomos-area-map"
    static let autonomosFleetMap = "autonomos-fleet-map"
    static let autonomosCycle = "autonomos-cycle"
    static let autonomosIncident = "autonomos-incident"
    static let autonomosAskPill = "autonomos-ask-pill"
    static let autonomosAreasSheet = "autonomos-areas-sheet"
    static let autonomosAreaBindCTA = "autonomos-area-bind-cta"
    static let autonomosAreaBindRowPrefix = "autonomos-area-bind-row-"
    static func autonomosAreaBindRow(_ id: String) -> String {
        autonomosAreaBindRowPrefix + id
    }
    static let autonomosGovernanceSheet = "autonomos-governance-sheet"
    static let autonomosReasonSheet = "autonomos-reason-sheet"
    static let autonomosReasonActor = "autonomos-reason-actor"
    static let autonomosReasonField = "autonomos-reason-field"
    static let autonomosReasonSubmit = "autonomos-reason-submit"
}
extension A11yID {
    static let autonomosHeader = "autonomos-header"
    static let autonomosBack = "autonomos-back"
    static let autonomosRefresh = "autonomos-refresh"
    static let autonomosStartRunReceipt = "autonomos-start-run-receipt"
    static let autonomosControlReceipt = "autonomos-control-receipt"
    static let autonomosControlError = "autonomos-control-error"
}
extension A11yID {
    static let autonomosTaskHealthQuiet = "autonomos-task-health-quiet"
    static let autonomosTaskHealthIncident = "autonomos-task-health-incident"
    static let autonomosLoadFailure = "autonomos-load-failure"
    static let autonomosRetry = "autonomos-retry"
}
extension A11yID {
    static let homeConversasSection = "home-conversas-section"
    static let homeOperacaoSection = "home-operacao-section"
    static let homeWorkspacesSection = "home-workspaces-section"
    static let homeConversasEntry = "home-conversas-entry"
    static let homeAutonomosEntry = "home-autonomos-entry"
}
