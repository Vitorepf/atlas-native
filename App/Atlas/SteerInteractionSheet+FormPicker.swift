import SwiftUI
import AtlasCore

// Steer form picker — peel de SteerInteractionSheet+FormHeader.

extension SteerInteractionSheet {
    var formScopePicker: some View {
        Picker("Escopo", selection: $scope) {
            ForEach(AtlasInteractionSteerScope.allCases, id: \.self) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier(A11yID.steerScope)
        .accessibilityLabel(spokenScopeLabel(scope))
    }
}
