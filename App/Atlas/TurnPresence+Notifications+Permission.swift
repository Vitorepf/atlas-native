import Foundation
import UserNotifications

// Permissão no primeiro turno — peel de TurnPresence+Notifications.

@MainActor
extension TurnPresence {
    /// Pede permissão no PRIMEIRO turno concluído (momento de valor real),
    /// nunca no launch — UX de permissão digna.
    func requestPermissionOnce() async {
        guard !askedPermission else { return }
        askedPermission = true
        // `await` de propósito: sem esperar o veredito, a notificação sai antes
        // de existir permissão e o iOS a descarta calada.
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }
}
