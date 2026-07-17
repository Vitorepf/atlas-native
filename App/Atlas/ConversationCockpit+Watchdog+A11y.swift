import Foundation

/// Spoken do watchdog de silêncio — peel de ConversationCockpit+Watchdog (CICLO C).
/// Só fala quando o stream publica streaming e o contador é real.

enum SilenceWatchdogA11y {
    static func spoken(seconds: Int) -> String {
        "execução ao vivo sem novos eventos há \(seconds) segundos"
    }
}
