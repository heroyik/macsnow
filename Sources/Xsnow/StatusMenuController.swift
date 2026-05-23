import AppKit

@MainActor
final class StatusMenuController {
    var onToggleSnow: (() -> Void)?
    var onSelectDensity: ((SnowDensity) -> Void)?
    var onAdjustWind: ((Double) -> Void)?
    var onToggleDisplay: ((String) -> Void)?
    var onQuit: (() -> Void)?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let toggleItem = NSMenuItem(title: "Stop Snow", action: #selector(toggleSnow), keyEquivalent: "")
    private let densityMenu = NSMenu()
    private let displaysMenu = NSMenu()
    private let debugItem = NSMenuItem(title: "Debug: -", action: nil, keyEquivalent: "")
    private var displayItemsByID: [String: NSMenuItem] = [:]

    func configure(isSnowEnabled: Bool) {
        statusItem.button?.title = "❄︎"
        statusItem.button?.toolTip = "Xsnow"

        toggleItem.target = self
        menu.addItem(toggleItem)

        let densityRoot = NSMenuItem(title: "Density", action: nil, keyEquivalent: "")
        menu.addItem(densityRoot)
        menu.setSubmenu(densityMenu, for: densityRoot)
        for density in SnowDensity.allCases {
            let item = NSMenuItem(title: density.title, action: #selector(selectDensity(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = density.rawValue
            densityMenu.addItem(item)
        }

        let windRoot = NSMenuItem(title: "Wind", action: nil, keyEquivalent: "")
        let windMenu = NSMenu()
        menu.addItem(windRoot)
        menu.setSubmenu(windMenu, for: windRoot)
        for option in [0.0, 0.2, 0.5] {
            let item = NSMenuItem(title: windTitle(for: option), action: #selector(selectWind(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = option
            windMenu.addItem(item)
        }

        let displaysRoot = NSMenuItem(title: "Displays", action: nil, keyEquivalent: "")
        menu.addItem(displaysRoot)
        menu.setSubmenu(displaysMenu, for: displaysRoot)

        debugItem.isEnabled = false
        menu.addItem(debugItem)
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

    func setDensity(_ density: SnowDensity) {
        for item in densityMenu.items {
            item.state = (item.representedObject as? String) == density.rawValue ? .on : .off
        }
    }

    func updateDisplays(_ displays: [(identity: DisplayIdentity, isEnabled: Bool)]) {
        displaysMenu.removeAllItems()
        displayItemsByID.removeAll()

        if displays.isEmpty {
            let item = NSMenuItem(title: "No Displays", action: nil, keyEquivalent: "")
            item.isEnabled = false
            displaysMenu.addItem(item)
            return
        }

        for display in displays {
            let item = NSMenuItem(title: display.identity.title, action: #selector(toggleDisplay(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = display.identity.id
            item.state = display.isEnabled ? .on : .off
            displaysMenu.addItem(item)
            displayItemsByID[display.identity.id] = item
        }
    }

    func updateDebug(overlayCount: Int, activeSceneCount: Int, density: SnowDensity, scannedWindowCount: Int) {
        debugItem.title = "Debug: overlays \(overlayCount), active \(activeSceneCount), windows \(scannedWindowCount), \(density.title)"
    }

    @objc private func toggleSnow() {
        onToggleSnow?()
    }

    @objc private func selectDensity(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let density = SnowDensity(rawValue: rawValue)
        else {
            return
        }
        onSelectDensity?(density)
    }

    @objc private func selectWind(_ sender: NSMenuItem) {
        guard let wind = sender.representedObject as? Double else {
            return
        }
        onAdjustWind?(wind)
    }

    @objc private func toggleDisplay(_ sender: NSMenuItem) {
        guard let displayID = sender.representedObject as? String else {
            return
        }
        onToggleDisplay?(displayID)
    }

    @objc private func quit() {
        onQuit?()
    }

    private func windTitle(for value: Double) -> String {
        switch value {
        case 0:
            "Off"
        case 0.2:
            "Light"
        default:
            "Medium"
        }
    }
}
