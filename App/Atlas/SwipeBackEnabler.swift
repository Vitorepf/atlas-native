import SwiftUI
import UIKit

// Gesto de voltar pela borda — devolvido às telas de chrome próprio.
//
// UIKit desliga o interactivePopGestureRecognizer quando a barra nativa está
// oculta. O delegate vive no PRÓPRIO UINavigationController (viewDidLoad é
// @objc — override em extension é legal): é o único anexo que o NavigationStack
// do iOS 18+ não re-seta. O shim embutido por tela (SwipeBackEnabler) nunca
// segurava o delegate e foi removido — provado por AtlasSwipeBackTests.
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    /// Só permite o pop quando há para onde voltar — a raiz nunca trava.
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
