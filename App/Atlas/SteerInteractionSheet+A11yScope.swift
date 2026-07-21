import Foundation
import AtlasCore

// Scope spoken — peel de SteerInteractionSheet+A11y.
// Receipt → SteerInteractionSheet+A11yReceipt.swift
// Submit → SteerInteractionSheet+A11ySubmit.swift

extension SteerInteractionSheet {
    func spokenScopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "escopo passo atual"
        case .replan: return "escopo replanejamento"
        }
    }
}
