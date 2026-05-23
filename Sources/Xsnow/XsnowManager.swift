import AppKit

@MainActor
final class XsnowManager {
    private let displayDetector: DisplayDetector
    private let statusMenuController: StatusMenuController
    private let settingsStore: SettingsStore
    private let windowLayoutScanner: WindowLayoutScanner
    private var settings: XsnowGlobalSettings
    private var displayControllers: [DisplayController] = []
    private var scannedWindows: [WindowSnapshot] = []

    init() {
        displayDetector = DisplayDetector()
        statusMenuController = StatusMenuController()
        settingsStore = SettingsStore()
        windowLayoutScanner = WindowLayoutScanner()
        settings = settingsStore.load()

        statusMenuController.onToggleSnow = { [weak self] in
            guard let self else { return }
            self.setSnowEnabled(!self.settings.isSnowEnabled)
        }
        statusMenuController.onSelectDensity = { [weak self] density in
            self?.setDensity(density)
        }
        statusMenuController.onAdjustWind = { [weak self] windStrength in
            self?.setWindStrength(windStrength)
        }
        statusMenuController.onToggleDisplay = { [weak self] displayID in
            self?.toggleDisplay(displayID)
        }
        statusMenuController.onQuit = {
            NSApplication.shared.terminate(nil)
        }
        displayDetector.onDisplaysChanged = { [weak self] in
            self?.rebuildDisplayControllers()
        }
        windowLayoutScanner.onSnapshot = { [weak self] windows in
            self?.scannedWindows = windows
            self?.updateMenuState()
        }
    }

    func start() {
        statusMenuController.configure(isSnowEnabled: settings.isSnowEnabled)
        statusMenuController.setDensity(settings.density)
        displayDetector.start()
        windowLayoutScanner.start()
        observePowerNotifications()
        rebuildDisplayControllers()
    }

    func stop() {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        displayDetector.stop()
        windowLayoutScanner.stop()
        displayControllers.forEach { $0.close() }
        displayControllers.removeAll()
    }

    private func setSnowEnabled(_ enabled: Bool) {
        settings.isSnowEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setSnowEnabled(enabled)
        applySettingsToDisplays()
    }

    private func rebuildDisplayControllers() {
        displayControllers.forEach { $0.close() }
        displayControllers = NSScreen.screens.enumerated().map { index, screen in
            let identity = DisplayIdentity(screen: screen, index: index)
            let controller = DisplayController(screen: screen, identity: identity)
            controller.show()
            return controller
        }
        applySettingsToDisplays()
        updateMenuState()
    }

    private func setDensity(_ density: SnowDensity) {
        settings.density = density
        settingsStore.save(settings)
        statusMenuController.setDensity(density)
        applySettingsToDisplays()
        updateMenuState()
    }

    private func setWindStrength(_ windStrength: Double) {
        settings.windStrength = windStrength
        settingsStore.save(settings)
        applySettingsToDisplays()
    }

    private func toggleDisplay(_ displayID: String) {
        var displaySettings = settings.perDisplay[displayID] ?? XsnowDisplaySettings()
        displaySettings.isEnabled.toggle()
        settings.perDisplay[displayID] = displaySettings
        settingsStore.save(settings)
        applySettingsToDisplays()
        updateMenuState()
    }

    private func applySettingsToDisplays() {
        for controller in displayControllers {
            let displaySettings = settings.perDisplay[controller.identity.id] ?? XsnowDisplaySettings()
            let enabled = settings.isSnowEnabled && displaySettings.isEnabled
            controller.apply(density: settings.density, windStrength: settings.windStrength)
            controller.setSnowEnabled(enabled)
        }
    }

    private func updateMenuState() {
        let displays = displayControllers.map { controller in
            let displaySettings = settings.perDisplay[controller.identity.id] ?? XsnowDisplaySettings()
            return (identity: controller.identity, isEnabled: displaySettings.isEnabled)
        }
        statusMenuController.updateDisplays(displays)
        statusMenuController.updateDebug(
            overlayCount: displayControllers.count,
            activeSceneCount: displayControllers.filter(\.isSnowActive).count,
            density: settings.density,
            scannedWindowCount: scannedWindows.count
        )
    }

    private func observePowerNotifications() {
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    @objc private func handleWillSleep() {
        displayControllers.forEach { $0.setSnowEnabled(false) }
        updateMenuState()
    }

    @objc private func handleDidWake() {
        applySettingsToDisplays()
        updateMenuState()
    }
}
