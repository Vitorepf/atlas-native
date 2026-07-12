import Foundation

// Estratégia de chave canônica do AtlasCore. Foundation's `.convertFromSnakeCase`
// tem um bug pra chaves com dígito+letra: `total_jobs_24h` vira `totalJobs24H`
// (H maiúsculo, via `.capitalized`) e `input_microusd_per_1k` vira `...Per1K`.
// Isso quebra o decode de campos como total_jobs_24h, failed_24h, usage_24h,
// input/output_microusd_per_1k — e o padrão do repo é NÃO escrever CodingKeys.
//
// Solução: uma conversão snake→camel intuitiva (maiúscula só no 1º caractere de
// cada componente após "_", dígitos intactos) — casa exatamente os nomes camelCase
// que qualquer dev TS/JS escreveria (totalJobs24h, per1k) e é idêntica ao
// `.convertFromSnakeCase` pra todas as chaves SEM adjacência dígito-letra.
// Um `let` global + esta chave cobrem toda a superfície, hoje e nas próximas fases.

struct AtlasCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init(_ s: String) { stringValue = s; intValue = nil }
    init?(stringValue: String) { self.stringValue = stringValue; intValue = nil }
    init?(intValue: Int) { self.intValue = intValue; stringValue = String(intValue) }
}

/// snake_case → camelCase intuitivo. `total_jobs_24h` → `totalJobs24h`,
/// `input_microusd_per_1k` → `inputMicrousdPer1k`, `message_count` → `messageCount`.
func atlasSnakeToCamel(_ s: String) -> String {
    guard s.contains("_") else { return s }
    var result = ""
    var seenFirst = false
    var leading = true
    for component in s.split(separator: "_", omittingEmptySubsequences: false) {
        if component.isEmpty {
            if leading { result += "_" }   // preserva underscores à esquerda (ex: _id)
            continue
        }
        leading = false
        if !seenFirst {
            result += String(component)     // 1º componente inalterado
            seenFirst = true
        } else if let first = component.first {
            result += first.uppercased() + component.dropFirst()  // resto: só 1º char maiúsculo
        }
    }
    return result
}

/// A estratégia compartilhada — produção (AtlasClient) e golden checks usam ESTA,
/// então os checks validam exatamente o caminho de decode real.
public let atlasSnakeKeyDecoding: JSONDecoder.KeyDecodingStrategy = .custom { path in
    guard let last = path.last else { return AtlasCodingKey("") }
    return AtlasCodingKey(atlasSnakeToCamel(last.stringValue))
}
