import SwiftUI
import PhotosUI
import AtlasCore

// O init voltou para ConversationView.swift: o backing `_model` de @State só é
// acessível no mesmo arquivo (limitação Swift). initModelState continua no peel
// ModelState.
