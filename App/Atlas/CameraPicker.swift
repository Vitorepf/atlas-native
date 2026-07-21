import Foundation
import SwiftUI
import UIKit

// Cycle 043 fuse → CameraPicker.swift

// zero lógica além de entregar os bytes; o AtlasImaging normaliza depois.
struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void
    var onCaptureFailed: () -> Void = {}
    var onCancel: () -> Void = {}
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeUIViewController(context: Context) -> UIImagePickerController {
        makeCameraPicker(context: context)
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {
        applyReduceMotion(vc)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
}

/// Cancelar = silêncio total (nunca toast de anexo); falha só quando bytes não saem.

enum CameraPickerA11y {
    static let spokenSurface = "câmera para anexar foto"
    static let spokenHint = "confirme a captura para anexar; cancelar não adiciona nada"
    static let captureFailedToast = "não consegui capturar a foto"

    static let spokenChooseCamera = "capturar foto na câmera"
    static let spokenChooseCameraHint = "abre a câmera; nada é anexado até confirmar a captura"
}

extension CameraPicker.Coordinator {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.onCancel()
        parent.dismiss()
    }
}

extension CameraPicker {
    func makeCameraPicker(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        applyReduceMotion(picker)
        return picker
    }
}

extension CameraPicker {
    func applyReduceMotion(_ picker: UIImagePickerController) {
        if reduceMotion {
            picker.modalTransitionStyle = .crossDissolve
        }
    }
}

extension CameraPicker {
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.92) {
                parent.onCapture(data)
            } else {
                parent.onCaptureFailed()
            }
            parent.dismiss()
        }
    }
}
