import SwiftUI
import WidgetKit
import ActivityKit
import AtlasCore

// Lock queue capsule — peel de AtlasTurnLockScreen+Title.
// Label → AtlasTurnLockScreen+QueueCapsule+Label.swift
// Chrome → AtlasTurnLockScreen+QueueCapsule+Chrome.swift

extension LockScreenView {
    @ViewBuilder
    var queueCapsule: some View {
        // M87 / E-A5: fila N como cápsula gold distinta no título
        if let queued = context.state.queueLabel {
            queueCapsuleChrome(queueCapsuleLabel(queued))
        }
    }
}
