import SwiftUI
import AtlasCore

// Ask/Why sheets bind — peel de AtlasCodeView+SheetsModifier.

extension AtlasCodeSheetsModifier {
  func askWhySheetsBind<Content: View>(_ content: Content) -> some View {
    content.modifier(AtlasCodeAskWhySheetsModifier(
      session: session,
      model: model,
      askModel: askModel,
      showsAskCard: $showsAskCard,
      whyFileTarget: $whyFileTarget,
      askThreadId: $askThreadId,
      askDraft: $askDraft
    ))
  }
}
