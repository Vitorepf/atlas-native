import SwiftUI
import UIKit

// Camera RM transition — peel de CameraPicker.

extension CameraPicker {
    func applyReduceMotion(_ picker: UIImagePickerController) {
        if reduceMotion {
            picker.modalTransitionStyle = .crossDissolve
        }
    }
}
