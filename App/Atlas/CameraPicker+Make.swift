import SwiftUI
import UIKit

// Camera picker factory — peel de CameraPicker.

extension CameraPicker {
    func makeCameraPicker(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        applyReduceMotion(picker)
        return picker
    }
}
