import Foundation

extension AtlasLongMessage {
    struct Chunk: Sendable {
        let index: Int
        let start: Int
        let end: Int
        let text: String
        let preview: String
        let score: Int
    }

    static func chunks(for input: String) -> [Chunk] {
        let normalized = input.replacingOccurrences(of: "\r\n", with: "\n")
        let blocks = paragraphBlocks(normalized)
        var texts: [(text: String, start: Int)] = []
        var current = ""
        var currentStart = 0
        var cursor = 0

        func flush() {
            let text = current.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return }
            texts.append((text, currentStart))
            current = ""
            currentStart = cursor
        }

        for block in blocks.isEmpty ? [normalized] : blocks {
            let blockLength = block.utf16.count
            let joined = current.isEmpty ? block : current + "\n\n" + block
            if !current.isEmpty, joined.utf16.count > chunkUTF16 { flush() }

            if blockLength > chunkUTF16 {
                for slice in splitByUTF16(block, maximum: chunkUTF16) {
                    current = slice
                    currentStart = cursor
                    flush()
                    cursor += slice.utf16.count
                }
                cursor += 2
                currentStart = cursor
                continue
            }

            if current.isEmpty { currentStart = cursor }
            current = current.isEmpty ? block : current + "\n\n" + block
            cursor += blockLength + 2
        }
        flush()
        if texts.isEmpty { texts = [(input, 0)] }

        return texts.enumerated().map { offset, value in
            let provisional = Chunk(
                index: offset + 1,
                start: value.start,
                end: value.start + value.text.utf16.count,
                text: value.text,
                preview: compactPreview(value.text, maximum: 420),
                score: 0
            )
            return Chunk(
                index: provisional.index, start: provisional.start, end: provisional.end,
                text: provisional.text, preview: provisional.preview,
                score: score(provisional)
            )
        }
    }

    static func paragraphBlocks(_ input: String) -> [String] {
        var blocks: [String] = []
        var lines: [Substring] = []
        func flush() {
            let block = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !block.isEmpty { blocks.append(block) }
            lines.removeAll(keepingCapacity: true)
        }
        for line in input.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { flush() }
            else { lines.append(line) }
        }
        flush()
        return blocks
    }

    static func splitByUTF16(_ text: String, maximum: Int) -> [String] {
        guard maximum > 0 else { return [text] }
        var result: [String] = []
        var start = text.startIndex
        var cursor = start
        var units = 0
        while cursor < text.endIndex {
            let next = text.index(after: cursor)
            let size = text[cursor..<next].utf16.count
            if units > 0, units + size > maximum {
                result.append(String(text[start..<cursor]))
                start = cursor
                units = 0
            }
            units += size
            cursor = next
        }
        if start < text.endIndex { result.append(String(text[start..<text.endIndex])) }
        return result
    }
}
