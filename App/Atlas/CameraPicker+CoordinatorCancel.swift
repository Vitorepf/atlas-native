import SwiftUI
import UIKit

// Cancel path — peel de CameraPicker+Coordinator.

extension CameraPicker.Coordinator {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.onCancel()
        parent.dismiss()
    }
}
