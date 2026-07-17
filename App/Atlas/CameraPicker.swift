import SwiftUI
import UIKit

// Câmera → Data (JPEG) → model.addImage(source: "camera"). Representable fino:
// zero lógica além de entregar os bytes; o AtlasImaging normaliza depois.
// Coordinator → CameraPicker+Coordinator.swift
// RM → CameraPicker+ReduceMotion.swift
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
        applyReduceMotion(picker)
        return picker
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {
        applyReduceMotion(vc)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
}
