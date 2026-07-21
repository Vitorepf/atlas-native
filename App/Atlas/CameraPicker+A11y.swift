import Foundation
import SwiftUI
import UIKit

// Cycle 041 fuse → CameraPicker+A11y.swift

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
