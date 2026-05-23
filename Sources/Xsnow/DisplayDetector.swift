import AppKit

@MainActor
final class DisplayDetector {
    var onDisplaysChanged: (() -> Void)?

    func start() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displaysChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func stop() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func displaysChanged() {
        onDisplaysChanged?()
    }
}
