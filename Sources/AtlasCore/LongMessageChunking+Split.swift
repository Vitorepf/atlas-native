import Foundation

extension AtlasLongMessage {
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
