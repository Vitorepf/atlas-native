import SwiftUI
import UIKit

// Cycle 041 fuse → CameraPicker.swift

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
