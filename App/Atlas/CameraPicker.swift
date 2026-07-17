import SwiftUI
import UIKit

// Câmera → Data (JPEG) → model.addImage(source: "camera"). Representable fino:
// zero lógica além de entregar os bytes; o AtlasImaging normaliza depois.
// Coordinator → CameraPicker+Coordinator.swift
struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void
    var onCaptureFailed: () -> Void = {}
    var onCancel: () -> Void = {}
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        if reduceMotion {
            picker.modalTransitionStyle = .crossDissolve
        }
        return picker
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {
        if reduceMotion {
            vc.modalTransitionStyle = .crossDissolve
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
}
