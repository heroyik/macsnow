import AppKit
import SpriteKit

@MainActor
final class XPMTextureCache {
    private struct RGBAColor {
        let red: UInt8
        let green: UInt8
        let blue: UInt8
        let alpha: UInt8

        static let clear = RGBAColor(red: 0, green: 0, blue: 0, alpha: 0)
        static let black = RGBAColor(red: 0, green: 0, blue: 0, alpha: 255)
        static let white = RGBAColor(red: 255, green: 255, blue: 255, alpha: 255)
        static let redColor = RGBAColor(red: 255, green: 0, blue: 0, alpha: 255)
        static let greenColor = RGBAColor(red: 0, green: 255, blue: 0, alpha: 255)
        static let blueColor = RGBAColor(red: 0, green: 0, blue: 255, alpha: 255)
        static let yellow = RGBAColor(red: 255, green: 255, blue: 0, alpha: 255)
    }

    static let shared = XPMTextureCache()

    private var cache: [String: SKTexture] = [:]

    private init() {}

    func texture(named name: String) -> SKTexture? {
        if let cached = cache[name] {
            return cached
        }

        guard
            let url = pixmapURL(named: name),
            let content = try? String(contentsOf: url, encoding: .utf8),
            let image = Self.makeImage(from: content)
        else {
            return nil
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        cache[name] = texture
        return texture
    }

    private func pixmapURL(named name: String) -> URL? {
        let fileManager = FileManager.default
        let cwd = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        var candidates: [URL] = []
        if let resourceURL = Bundle.main.resourceURL {
            candidates.append(resourceURL.appendingPathComponent("Pixmaps/\(name)"))
        }
        candidates += [
            cwd.appendingPathComponent("xsnow-org/xsnow-3.9.1/src/Pixmaps/\(name)"),
            cwd.appendingPathComponent("../xsnow-org/xsnow-3.9.1/src/Pixmaps/\(name)"),
            URL(fileURLWithPath: "/Users/nick/proj/macsnow/xsnow-org/xsnow-3.9.1/src/Pixmaps/\(name)")
        ]

        return candidates.first { fileManager.fileExists(atPath: $0.path) }
    }

    private static func makeImage(from content: String) -> NSImage? {
        let entries = content
            .split(separator: "\n")
            .compactMap { line -> String? in
                guard let firstQuote = line.firstIndex(of: "\"") else {
                    return nil
                }
                let afterFirst = line.index(after: firstQuote)
                guard let secondQuote = line[afterFirst...].firstIndex(of: "\"") else {
                    return nil
                }
                return String(line[afterFirst..<secondQuote])
            }

        guard let headerIndex = entries.firstIndex(where: { entry in
            let parts = entry.split { $0 == " " || $0 == "\t" }
            return parts.count >= 4 && parts.prefix(4).allSatisfy { Int($0) != nil }
        }) else {
            return nil
        }

        let header = entries[headerIndex]
        let headerParts = header.split { $0 == " " || $0 == "\t" }.compactMap { Int($0) }
        guard headerParts.count >= 4 else {
            return nil
        }

        let payload = Array(entries.dropFirst(headerIndex + 1))
        let width = headerParts[0]
        let height = headerParts[1]
        let colorCount = headerParts[2]
        let charsPerPixel = headerParts[3]
        guard width > 0, height > 0, charsPerPixel > 0, payload.count >= colorCount + height else {
            return nil
        }

        var colors: [String: RGBAColor] = [:]
        for entry in payload.prefix(colorCount) {
            guard entry.count >= charsPerPixel else {
                continue
            }
            let key = String(entry.prefix(charsPerPixel))
            colors[key] = parseColor(from: entry) ?? .clear
        }

        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        let pixelRows = payload.dropFirst(colorCount).prefix(height)
        guard pixelRows.count == height, pixelRows.allSatisfy({ $0.count >= width * charsPerPixel }) else {
            return nil
        }

        for (y, row) in pixelRows.enumerated() {
            var index = row.startIndex
            for x in 0..<width {
                guard index < row.endIndex else {
                    break
                }
                let end = row.index(index, offsetBy: charsPerPixel, limitedBy: row.endIndex) ?? row.endIndex
                let key = String(row[index..<end])
                let color = colors[key] ?? .clear
                let offset = (y * width + x) * 4
                pixels[offset] = color.red
                pixels[offset + 1] = color.green
                pixels[offset + 2] = color.blue
                pixels[offset + 3] = color.alpha
                index = end
            }
        }

        let data = Data(pixels)
        guard
            let provider = CGDataProvider(data: data as CFData),
            let cgImage = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
            )
        else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }

    private static func parseColor(from entry: String) -> RGBAColor? {
        let parts = entry.split { $0 == " " || $0 == "\t" }.map(String.init)
        guard let cIndex = parts.firstIndex(of: "c"), cIndex + 1 < parts.count else {
            return nil
        }

        let value = parts[cIndex + 1]
        if value.lowercased() == "none" {
            return .clear
        }

        guard value.hasPrefix("#") else {
            return namedColor(value)
        }

        let hex = String(value.dropFirst())
        guard hex.count == 6, let raw = Int(hex, radix: 16) else {
            return nil
        }

        return RGBAColor(
            red: UInt8((raw >> 16) & 0xff),
            green: UInt8((raw >> 8) & 0xff),
            blue: UInt8(raw & 0xff),
            alpha: 255
        )
    }

    private static func namedColor(_ value: String) -> RGBAColor? {
        let lowercased = value.lowercased()
        if lowercased.hasPrefix("gray") || lowercased.hasPrefix("grey") {
            let prefixLength = lowercased.hasPrefix("gray") ? 4 : 4
            let rawPercent = String(lowercased.dropFirst(prefixLength))
            if let percent = Int(rawPercent) {
                let component = UInt8(max(0, min(255, percent * 255 / 100)))
                return RGBAColor(red: component, green: component, blue: component, alpha: 255)
            }
        }

        switch lowercased {
        case "black": return .black
        case "white": return .white
        case "red": return .redColor
        case "green": return .greenColor
        case "blue": return .blueColor
        case "yellow": return .yellow
        case "gainsboro": return RGBAColor(red: 220, green: 220, blue: 220, alpha: 255)
        case "snow": return RGBAColor(red: 255, green: 250, blue: 250, alpha: 255)
        case "none": return .clear
        default: return nil
        }
    }
}
