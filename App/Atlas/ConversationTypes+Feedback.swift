import Foundation
import AtlasCore

/// Feedback editorial do operador — peel de ConversationTypes.
/// Label → ConversationTypes+Feedback+Label.swift
/// Payload → ConversationTypes+Feedback+Payload.swift
/// ActiveAction → ConversationTypes+Feedback+ActiveAction.swift
enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }
}
