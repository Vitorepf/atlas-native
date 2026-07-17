import SwiftUI
import AtlasCore

// Handoff subline — peel de ConversationChromeSheets+Receipt+Copy.
// Ready → ConversationChromeSheets+Receipt+Subline+Ready.swift
// Pending → ConversationChromeSheets+Receipt+Subline+Pending.swift

extension ConversationHandoffReceipt {
    var subline: String {
        let route = "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment
        if isReady { return readySubline(route: route, thread: thread, age: age) }
        return pendingSubline(route: route, thread: thread, age: age)
    }
}
