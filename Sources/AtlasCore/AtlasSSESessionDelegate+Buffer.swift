import Foundation

/// Buffer/drain do delegate SSE — peel de AtlasClient+SSE.

extension AtlasSSESessionDelegate {
    func drainCompleteFrames() {
        var cursor = buffer.startIndex
        var consumedEnd: Data.Index?
        while let range = firstDelimiter(in: buffer, from: cursor) {
            let frameData = buffer[cursor..<range.lowerBound]
            dispatch(frameData)
            cursor = range.upperBound
            consumedEnd = range.upperBound
        }
        if let consumedEnd {
            buffer.removeSubrange(..<consumedEnd)
        }
    }

    func drainRemainder() {
        guard !buffer.isEmpty else { return }
        let remainder = buffer
        buffer.removeAll(keepingCapacity: false)
        dispatch(remainder)
    }

    func dispatch(_ data: Data) {
        guard !data.isEmpty else { return }
        emit(dispatchAtlasAiStreamFrame(data, decoder: decoder), traceId: traceId, into: continuation)
    }

    func firstDelimiter(in data: Data, from start: Data.Index) -> Range<Data.Index>? {
        let searchRange = start..<data.endIndex
        let lf = data.range(of: Self.lfDelimiter, options: [], in: searchRange)
        let crlf = data.range(of: Self.crlfDelimiter, options: [], in: searchRange)
        switch (lf, crlf) {
        case (.some(let a), .some(let b)): return a.lowerBound < b.lowerBound ? a : b
        case (.some(let a), .none): return a
        case (.none, .some(let b)): return b
        case (.none, .none): return nil
        }
    }

    func finish(throwing error: Error? = nil) {
        guard !finished else { return }
        finished = true
        if let error { continuation.finish(throwing: error) }
        else { continuation.finish() }
    }
}
