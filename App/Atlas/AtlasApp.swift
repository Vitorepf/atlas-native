import AtlasCore
import SwiftUI
import Foundation
import Security

// Cycle 044 fuse → AtlasApp.swift

// Ponto de entrada do app SwiftUI puro. Casca fina: cria a sessão (que segura o
// AtlasClient do AtlasCore) e injeta no ambiente. Zero lógica de negócio aqui.
@main
struct AtlasApp: App {
    @Environment(\.scenePhase) var scenePhase
    @State var session = AtlasSession()

    init() {
        // Curva Dynamic Type do sans lida UMA vez na main — body nunca toca UIKit.
        AtlasSansScale.prime()
    }

    var body: some Scene {
        WindowGroup {
            atlasSceneLifecycle(
                RootView()
                    .environment(session)
            )
        }
    }
}

extension AtlasApp {
    func atlasSceneBootstrap<Content: View>(_ content: Content) -> some View {
        content.task {
            NightlyProposalController.shared.installAsNotificationDelegate()
            LiveActivityRemoteBridge.shared.bootstrap(
                client: session.client,
                installationId: AtlasInstallationIdentity.id
            )
            session.setLiveSessionsPollingActive(scenePhase == .active)
        }
    }
}

extension AtlasApp {
    func atlasScenePhaseLifecycle<Content: View>(_ content: Content) -> some View {
        content.onChange(of: scenePhase) { _, phase in
            session.setLiveSessionsPollingActive(phase == .active)
            if phase == .background {
                Task {
                    await AtlasNativeSnapshotWriter.shared.write()
                    await NightlyProposalController.shared.scheduleForBackground()
                }
            }
        }
    }
}

extension AtlasApp {
    func atlasSceneLifecycle<Content: View>(_ content: Content) -> some View {
        atlasScenePhaseLifecycle(atlasSceneBootstrap(content))
    }
}


enum AtlasTokenStore {
    private static let service = "com.vitor.atlas.native"
    private static let account = "ATLAS_TOKEN"

    static func resolve(configuredToken: String) -> String {
        let trimmed = configuredToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            save(trimmed)
            return trimmed
        }
        return load() ?? ""
    }

    private static func load() -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty else { return nil }
        return token
    }

    private static func save(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        var query = baseQuery()
        let attributes = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            _ = SecItemAdd(query as CFDictionary, nil)
        }
    }

    private static func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
