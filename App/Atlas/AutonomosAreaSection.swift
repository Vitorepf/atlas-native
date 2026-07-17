import SwiftUI

/// C13: disponibilidade vem de canControlSelectedArea (POSTs existem e são
/// governados) — nunca de live.readOnly, que descreve apenas o GET.
/// Cycle → AutonomosAreaSection+Cycle.swift
/// Primary → AutonomosAreaSection+Primary.swift
/// A11y → AutonomosAreaSection+A11yChrome.swift
struct AutonomosAreaControls: View {
    let areaName: String
    let isPaused: Bool
    let canControl: Bool
    let onResume: () -> Void
    let onPause: () -> Void
    let onTransfer: () -> Void
    let onKill: () -> Void
    let onDryRun: () -> Void
    let onExecute: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        areaControlsA11yChrome(
            VStack(alignment: .leading, spacing: 10) {
                primaryButtons
                cycleButtons
            }
        )
    }
}
