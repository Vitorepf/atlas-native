import SwiftUI
import UIKit

// Câmera → Data (JPEG) → model.addImage(source: "camera"). Representable fino:
// zero lógica além de entregar os bytes; o AtlasImaging normaliza depois.
// Coordinator → CameraPicker+Coordinator.swift
// RM → CameraPicker+ReduceMotion.swift
// Make → CameraPicker+Make.swift
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
