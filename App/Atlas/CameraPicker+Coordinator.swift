import SwiftUI
import UIKit

// Coordinator da câmera — peel de CameraPicker.
// Cancel → CameraPicker+CoordinatorCancel.swift

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
