import SwiftUI
import AtlasCore

// Status capsule — peel de AtlasCodeGraphChrome.
// Week → AtlasCodeGraphChrome+WeekMetric.swift
// Tokens → AtlasCodeGraphChrome+StatusTokens.swift
// Chrome → AtlasCodeGraphChrome+StatusChrome.swift

extension AtlasCodeView {
    /// Cápsula central e simétrica: a única voz do estado geral.
    var statusCapsule: some View {
        statusCapsuleChrome(
            HStack(spacing: 7) {
                Image(systemName: statusCapsuleSymbol)
                    .font(.system(size: 10, weight: .semibold))
                Text(model.statusHeadline)
                    .font(.system(size: 11, weight: .semibold))
                    .monospacedDigit()
            }
        )
    }
}
