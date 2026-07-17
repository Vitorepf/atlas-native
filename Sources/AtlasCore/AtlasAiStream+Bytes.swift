import Foundation

private enum AtlasAiSSEBytes {
    static let lf: UInt8 = 0x0A
    static let lineFeed = Data([0x0A])
    static let eventPrefix = Array("event:".utf8)
    static let dataPrefix = Array("data:".utf8)
}

public func dispatchAtlasAiStreamFrame(_ frame: Data, decoder: JSONDecoder) -> AtlasAiStreamFrame {
    var eventName = "message"
    var dataRanges: [Range<Data.Index>] = []
    var lineStart = frame.startIndex

    while lineStart <= frame.endIndex {
        var lineEnd = lineStart
        while lineEnd < frame.endIndex, frame[lineEnd] != AtlasAiSSEBytes.lf {
            lineEnd = frame.index(after: lineEnd)
        }

        let trimmedEnd = trimTrailingASCIIWhitespace(in: frame, from: lineStart, to: lineEnd)
        if hasASCIIPrefix(AtlasAiSSEBytes.eventPrefix, in: frame, from: lineStart, to: trimmedEnd) {
            let valueStart = trimLeadingASCIIWhitespace(in: frame, from: frame.index(lineStart, offsetBy: AtlasAiSSEBytes.eventPrefix.count), to: trimmedEnd)
            eventName = String(data: Data(frame[valueStart..<trimmedEnd]), encoding: .utf8) ?? ""
        } else if hasASCIIPrefix(AtlasAiSSEBytes.dataPrefix, in: frame, from: lineStart, to: trimmedEnd) {
            let valueStart = trimLeadingASCIIWhitespace(in: frame, from: frame.index(lineStart, offsetBy: AtlasAiSSEBytes.dataPrefix.count), to: trimmedEnd)
            dataRanges.append(valueStart..<trimmedEnd)
        }

        if lineEnd == frame.endIndex { break }
        lineStart = frame.index(after: lineEnd)
    }

    if dataRanges.isEmpty { return .ignored }

    let payloadData: Data
    if dataRanges.count == 1, let range = dataRanges.first {
        payloadData = frame[range]
    } else {
        var joined = Data()
        for (index, range) in dataRanges.enumerated() {
            if index > 0 { joined.append(AtlasAiSSEBytes.lineFeed) }
            joined.append(frame[range])
        }
        payloadData = joined
    }

    guard let payload = try? decoder.decode(JSONValue.self, from: payloadData) else {
        return .ignored
    }

    return dispatchAtlasAiStreamPayload(payload, eventName: eventName)
}

private func hasASCIIPrefix(_ prefix: [UInt8], in data: Data, from start: Data.Index, to end: Data.Index) -> Bool {
    guard data.distance(from: start, to: end) >= prefix.count else { return false }
    var cursor = start
    for byte in prefix {
        if data[cursor] != byte { return false }
        cursor = data.index(after: cursor)
    }
    return true
}

private func trimTrailingASCIIWhitespace(in data: Data, from start: Data.Index, to end: Data.Index) -> Data.Index {
    var cursor = end
    while cursor > start {
        let previous = data.index(before: cursor)
        if !isASCIIWhitespace(data[previous]) { break }
        cursor = previous
    }
    return cursor
}

private func trimLeadingASCIIWhitespace(in data: Data, from start: Data.Index, to end: Data.Index) -> Data.Index {
    var cursor = start
    while cursor < end, isASCIIWhitespace(data[cursor]) {
        cursor = data.index(after: cursor)
    }
    return cursor
}

private func isASCIIWhitespace(_ byte: UInt8) -> Bool {
    byte == 0x20 || byte == 0x09 || byte == 0x0A || byte == 0x0D
}
