import SwiftUI
import UIKit

// GOD-RESTRUCTURE: interaction helpers fused

// MARK: - PressableScale

struct PressableScale: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.96 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.6)),
                value: configuration.isPressed
            )
    }
}
// MARK: - SwipeBackEnabler

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
// MARK: - NavigationInteractivePopEnabler

struct NavigationInteractivePopEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Controller()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        (uiViewController as? Controller)?.enablePopIfNeeded()
    }

    private final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            enablePopIfNeeded()
        }

        func enablePopIfNeeded() {
            guard let nav = navigationController else { return }
            nav.interactivePopGestureRecognizer?.isEnabled = nav.viewControllers.count > 1
        }
    }
}
