import SwiftUI
import AtlasCore

/// Conteúdo loading / unavailable / available — peel de ChangeReviewSheet (régua ≤100).
/// Surface → ChangeReviewView+Surface.swift
/// Unavailable → ChangeReviewView+Unavailable.swift
/// Available → ChangeReviewView+Available.swift

extension ChangeReviewSheet {
    @ViewBuilder
    var content: some View {
        if review == nil {
            reviewUnavailableContent
        } else if let review {
            reviewAvailableContent(review)
        }
    }
}
