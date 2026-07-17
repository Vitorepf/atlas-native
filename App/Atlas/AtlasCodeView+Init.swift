import SwiftUI
import AtlasCore

// Init do grafo — peel de AtlasCodeView.

extension AtlasCodeView {
    init(client: AtlasClient, repo: String = "atlas-server") {
        _model = State(initialValue: AtlasCodeModel(client: client, repo: repo))
        _provenanceModel = State(initialValue: AtlasCodeProvenanceModel(client: client, repo: repo))
        _mirrorModel = State(initialValue: AtlasCodeMirrorModel(client: client, repo: repo))
        _askModel = State(initialValue: AtlasCodeAskModel(client: client, repo: repo))
    }
}
