import AppKit

@MainActor
final class XsnowManager {
    private let displayDetector: DisplayDetector
    private let statusMenuController: StatusMenuController
    private var displayControllers: [DisplayController] = []
    private var isSnowEnabled = true

    init() {
        displayDetector = DisplayDetector()
        statusMenuController = StatusMenuController()

        statusMenuController.onToggleSnow = { [weak self] in
            self?.setSnowEnabled(!(self?.isSnowEnabled ?? true))
        }
        statusMenuController.onQuit = {
            NSApplication.shared.terminate(nil)
        }
        displayDetector.onDisplaysChanged = { [weak self] in
            self?.rebuildDisplayControllers()
        }
    }

    func start() {
        statusMenuController.configure(isSnowEnabled: isSnowEnabled)
        displayDetector.start()
        observePowerNotifications()
        rebuildDisplayControllers()
    }

    func stop() {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        displayDetector.stop()
        displayControllers.forEach { $0.close() }
        displayControllers.removeAll()
    }

    private func setSnowEnabled(_ enabled: Bool) {
        isSnowEnabled = enabled
        statusMenuController.setSnowEnabled(enabled)
        displayControllers.forEach { $0.setSnowEnabled(enabled) }
    }

    private func rebuildDisplayControllers() {
        displayControllers.forEach { $0.close() }
        displayControllers = NSScreen.screens.map { screen in
            let controller = DisplayController(screen: screen)
            controller.show()
            controller.setSnowEnabled(isSnowEnabled)
            return controller
        }
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
    }

    @objc private func handleDidWake() {
        displayControllers.forEach { $0.setSnowEnabled(isSnowEnabled) }
    }
}
