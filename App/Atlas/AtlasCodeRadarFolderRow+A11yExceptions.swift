import Foundation
import AtlasCore

/// Exception count spoken — peel de AtlasCodeFolderRow+A11y.

enum AtlasCodeFolderRowA11yExceptions {
    static func exceptionPhrase(_ verifiedExceptionCount: Int) -> String? {
        guard verifiedExceptionCount > 0 else { return nil }
        return "\(verifiedExceptionCount) sem retorno\(verifiedExceptionCount == 1 ? "" : "s") verificado\(verifiedExceptionCount == 1 ? "" : "s")"
    }
}
