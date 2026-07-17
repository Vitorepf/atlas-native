import SwiftUI

// Banner chrome — peel de ConversationCockpit+ExecutionBanner.
// Row → ConversationCockpit+ExecutionBannerChrome+Row.swift
// Frame → ConversationCockpit+ExecutionBannerChrome+Frame.swift

extension ExecutionBanner {
    var bannerChrome: some View {
        bannerChromeFrame(bannerContentRow)
    }
}
