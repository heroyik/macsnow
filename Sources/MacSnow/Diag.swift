import Foundation

enum Diag {
    private static let path = "/tmp/macsnow-diag.txt"
    private static let queue = DispatchQueue(label: "local.macsnow.diag")

    static func log(_ message: String) {
        let line = "[MacSnowDiag] \(message)\n"
        queue.async {
            if let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: path)) {
                handle.seekToEndOfFile()
                handle.write(line.data(using: .utf8)!)
                try? handle.close()
            } else {
                try? line.data(using: .utf8)?.write(to: URL(fileURLWithPath: path))
            }
        }
        NSLog("%@", line.trimmingCharacters(in: .newlines))
    }
}
