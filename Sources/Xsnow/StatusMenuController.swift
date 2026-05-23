import AppKit

@MainActor
final class StatusMenuController {
    var onToggleSnow: (() -> Void)?
    var onQuit: (() -> Void)?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let toggleItem = NSMenuItem(title: "Stop Snow", action: #selector(toggleSnow), keyEquivalent: "")

    func configure(isSnowEnabled: Bool) {
        statusItem.button?.title = "❄︎"
        statusItem.button?.toolTip = "Xsnow"

        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Xsnow", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        setSnowEnabled(isSnowEnabled)
    }

    func setSnowEnabled(_ enabled: Bool) {
        toggleItem.title = enabled ? "Stop Snow" : "Start Snow"
        toggleItem.state = enabled ? .on : .off
    }

    @objc private func toggleSnow() {
        onToggleSnow?()
    }

    @objc private func quit() {
        onQuit?()
    }
}
