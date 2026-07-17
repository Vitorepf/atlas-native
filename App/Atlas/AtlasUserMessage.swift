import Foundation
import AtlasCore

/// Mensagens de erro amigáveis partilhadas entre models da casca.
// Stream → AtlasUserMessage+Stream.swift · URL → +URL.swift · API → +API.swift

func atlasUserMessage(for error: Error) -> String {
    if let message = atlasUserMessage(forStream: error) { return message }
    if let message = atlasUserMessage(forURL: error) { return message }
    if let message = atlasUserMessage(forAPI: error) { return message }
    return "A execução foi interrompida. Tente novamente."
}
