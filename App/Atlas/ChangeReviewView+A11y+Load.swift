import SwiftUI
import AtlasCore

/// Review sheet load spoken — peel de ChangeReviewView+A11y.

extension ChangeReviewSheet {
    func spokenReviewSheetLoadLabel() -> String? {
        if !loadFinished, review == nil { return "revisão de mudanças, consultando" }
        if loadFinished, review == nil { return "revisão de mudanças, indisponível" }
        return nil
    }
}
