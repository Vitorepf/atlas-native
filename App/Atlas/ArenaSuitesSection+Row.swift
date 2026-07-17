import SwiftUI
import AtlasCore

// A linha da suíte — struct-mãe RECONSTRUÍDA pós-merge Elite: os peels
// criaram as 10 extensões (leading/trailing/badges/sparkline), mas o arquivo
// da própria struct nunca chegou ao merge. Composição mínima a partir das
// folhas existentes.

struct ArenaSuiteRow: View {
    let suite: AtlasArenaSuite

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            suiteLeading
            Spacer(minLength: 8)
            suiteTrailing
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
