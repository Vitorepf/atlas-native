import Foundation
import UserNotifications

/// Delegate de notificações noturnas — peel de NightlyProposal.
/// Handle → NightlyProposal+DelegateHandle.swift

extension NightlyProposalController {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let route = userInfo["atlas.route"] as? String
        let workspaces = userInfo["atlas.workspaces"] as? [String]
        await MainActor.run {
            NightlyProposalController.shared.handle(route: route, workspaces: workspaces)
        }
    }
}
