import ActivityKit
import AtlasCore
import Foundation
import SwiftUI
import UIKit
import UserNotifications

// WAVE-116 TurnPresence host — Entry · shared · watch

extension TurnPresence {
    final class Entry {
        weak var model: ConversationModel?
        var threadTitle: String
        var threadId: ThreadID?
        var activityKey: TraceID?   // trace real que liga Activity ↔ conversa
        var activityStarted = false
        var ongoing = false        // C14: running OU paused — a sessão vive
        var visible = false
        var startedAt = Date()     // base local só para trace legado (timer nil)
        init(model: ConversationModel, threadTitle: String, threadId: ThreadID?) {
            self.model = model
            self.threadTitle = threadTitle
            self.threadId = threadId
        }
    }
}
extension TurnPresence {
    func watch(_ model: ConversationModel, threadTitle: String, threadId: ThreadID? = nil) {
        let id = ObjectIdentifier(model)
        if let existing = entries[id] {
            existing.threadTitle = threadTitle
            existing.threadId = threadId ?? model.threadId
            publishLiveSessions()
            return
        }
        let entry = Entry(model: model, threadTitle: threadTitle, threadId: threadId ?? model.threadId)
        entries[id] = entry
        observe(id)
    }

    func setVisible(_ model: ConversationModel, visible: Bool) {
        entries[ObjectIdentifier(model)]?.visible = visible
    }
}


@Observable @MainActor
final class TurnPresence {
    static let shared = TurnPresence()
    private init() {}

    private(set) var runningTitles: Set<String> = []

    var liveSessions: [LiveSessionSnapshot] = []

    @ObservationIgnored var entries: [ObjectIdentifier: Entry] = [:]
    @ObservationIgnored var askedPermission = false

    func syncRunning() {
        runningTitles = Set(entries.values.filter { $0.ongoing }.map { $0.threadTitle })
        publishLiveSessions()
        Task { await AtlasNativeSnapshotWriter.shared.write() }
    }

    var activeCount: Int { entries.values.filter { $0.ongoing }.count }
}
