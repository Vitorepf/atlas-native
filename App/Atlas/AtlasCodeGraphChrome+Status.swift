import SwiftUI
import AtlasCore

// Status capsule — peel de AtlasCodeGraphChrome.
// Week → AtlasCodeGraphChrome+WeekMetric.swift
// Tokens → AtlasCodeGraphChrome+StatusTokens.swift

extension AtlasCodeView {
    /// Cápsula central e simétrica: a única voz do estado geral.
    var statusCapsule: some View {
        HStack(spacing: 7) {
            Image(systemName: statusCapsuleSymbol)
                .font(.system(size: 10, weight: .semibold))
            Text(model.statusHeadline)
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
        }
        .foregroundStyle(statusCapsuleColor)
        .padding(.horizontal, 15)
        .padding(.vertical, 7)
        .background(Capsule().fill(statusCapsuleColor.opacity(0.09)))
        .overlay(Capsule().strokeBorder(statusCapsuleColor.opacity(0.35), lineWidth: 1))
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.scanState)
        .accessibilityLabel(AtlasCodeGraphA11y.spokenStatus(
            scanState: model.scanState, headline: model.statusHeadline
        ))
        .accessibilityIdentifier(A11yID.codeStatus)
    }
}
