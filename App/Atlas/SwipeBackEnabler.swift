import SwiftUI
import UIKit

// Gesto de voltar pela borda — devolvido às telas de chrome próprio.
//
// UIKit desliga o interactivePopGestureRecognizer quando a barra nativa
// está oculta (`navigationBarHidden(true)`). Este shim reanexa o gesto
// sem recriar chrome: o delegate só permite o pop quando há para onde
// voltar, então a home (raiz) nunca trava.

struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ controller: Controller, context: Context) {}

    final class Controller: UIViewController, UIGestureRecognizerDelegate {
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            attach()
        }

        // didMove pode rodar antes do navigationController existir; o
        // viewDidAppear garante a hierarquia completa.
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            attach()
        }

        private func attach() {
            guard let pop = navigationController?.interactivePopGestureRecognizer else { return }
            pop.delegate = self
            pop.isEnabled = true
        }

        func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
            (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}

extension View {
    /// Aplicar junto de `navigationBarHidden(true)` — barra própria, gesto nativo.
    func atlasSwipeBack() -> some View {
        background(SwipeBackEnabler().frame(width: 0, height: 0))
    }
}
