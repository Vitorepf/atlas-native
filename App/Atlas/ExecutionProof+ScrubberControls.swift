import SwiftUI
import AtlasCore

// Controles slider/stepper — peel de ExecutionProof+Scrubber.
// Stepper → ExecutionProof+ScrubberControls+Stepper.swift
// Slider → ExecutionProof+ScrubberControls+Slider.swift

extension ExecutionProof {
    @ViewBuilder
    func replayControls(stampedCount: Int) -> some View {
        if reduceMotion {
            replayStepperControl(stampedCount: stampedCount)
        } else {
            replaySliderControl(stampedCount: stampedCount)
        }
    }
}
