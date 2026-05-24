import AppKit

struct DisplayIdentity: Hashable {
    let id: String
    let title: String

    init(screen: NSScreen, index: Int) {
        if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
            id = "screen-\(screenNumber.uint32Value)"
        } else {
            let frame = screen.frame
            id = "frame-\(Int(frame.origin.x))-\(Int(frame.origin.y))-\(Int(frame.width))-\(Int(frame.height))"
        }

        let size = screen.frame.size
        title = "Display \(index + 1) (\(Int(size.width))x\(Int(size.height)))"
    }
}
