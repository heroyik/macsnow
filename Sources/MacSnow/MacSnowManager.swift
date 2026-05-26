import AppKit

@MainActor
final class MacSnowManager {
    private let displayDetector: DisplayDetector
    private let statusMenuController: StatusMenuController
    private let settingsStore: SettingsStore
    private let windowLayoutScanner: WindowLayoutScanner
    private var settings: MacSnowGlobalSettings
    private var displayControllers: [DisplayController] = []
    private var scannedWindows: [WindowSnapshot] = []
    private var isWindowScannerRunning = false
    private var powerSaveTimer: Timer?

    init() {
        Diag.log("MacSnowManager.init() start")
        displayDetector = DisplayDetector()
        statusMenuController = StatusMenuController()
        settingsStore = SettingsStore()
        windowLayoutScanner = WindowLayoutScanner()
        settings = settingsStore.load()
        Diag.log("MacSnowManager.init() callbacks setup start")

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
        statusMenuController.onSelectWindDirection = { [weak self] direction in
            self?.setWindDirection(direction)
        }
        statusMenuController.onSelectVisualScale = { [weak self] scale in
            self?.setVisualScale(scale)
        }
        statusMenuController.onSelectSnowColorMode = { [weak self] mode in
            self?.setSnowColorMode(mode)
        }
        statusMenuController.onToggleCelestialEffects = { [weak self] in
            self?.setCelestialEffectsEnabled(!(self?.settings.isCelestialEffectsEnabled ?? true))
        }
        statusMenuController.onToggleAurora = { [weak self] in self?.setAuroraEnabled(!(self?.settings.isAuroraEnabled ?? true)) }
        statusMenuController.onToggleMoon = { [weak self] in self?.setMoonEnabled(!(self?.settings.isMoonEnabled ?? true)) }
        statusMenuController.onToggleStars = { [weak self] in self?.setStarsEnabled(!(self?.settings.areStarsEnabled ?? true)) }
        statusMenuController.onToggleMeteors = { [weak self] in self?.setMeteorsEnabled(!(self?.settings.areMeteorsEnabled ?? true)) }
        statusMenuController.onToggleBirds = { [weak self] in
            self?.setBirdsEnabled(!(self?.settings.areBirdsEnabled ?? true))
        }
        statusMenuController.onToggleSanta = { [weak self] in
            self?.setSantaEnabled(!(self?.settings.isSantaEnabled ?? true))
        }
        statusMenuController.onToggleScenery = { [weak self] in
            self?.setSceneryEnabled(!(self?.settings.isSceneryEnabled ?? true))
        }
        statusMenuController.onToggleTrees = { [weak self] in self?.setTreesEnabled(!(self?.settings.areTreesEnabled ?? true)) }
        statusMenuController.onToggleGiftTree = { [weak self] in self?.setGiftTreeEnabled(!(self?.settings.isGiftTreeEnabled ?? true)) }
        statusMenuController.onToggleSnowman = { [weak self] in self?.setSnowmanEnabled(!(self?.settings.isSnowmanEnabled ?? true)) }
        statusMenuController.onToggleHouse = { [weak self] in self?.setHouseEnabled(!(self?.settings.isHouseEnabled ?? true)) }
        statusMenuController.onToggleReindeer = { [weak self] in self?.setReindeerEnabled(!(self?.settings.isReindeerEnabled ?? true)) }
        statusMenuController.onToggleMoose = { [weak self] in self?.setMooseEnabled(!(self?.settings.isMooseEnabled ?? true)) }
        statusMenuController.onTogglePolarBear = { [weak self] in self?.setPolarBearEnabled(!(self?.settings.isPolarBearEnabled ?? true)) }
        statusMenuController.onToggleWinterObject = { [weak self] object in
            self?.toggleWinterObject(object)
        }
        statusMenuController.onToggleGroundAgent = { [weak self] in
            self?.setGroundAgentEnabled(!(self?.settings.isGroundAgentEnabled ?? true))
        }
        statusMenuController.onToggleGifts = { [weak self] in
            self?.setGiftsEnabled(!(self?.settings.areGiftsEnabled ?? true))
        }
        statusMenuController.onSelectObjectAmount = { [weak self] amount in
            self?.setObjectAmount(amount)
        }
        statusMenuController.onSelectSantaStyle = { [weak self] style in
            self?.setSantaStyle(style)
        }
        statusMenuController.onSelectSantaSpeed = { [weak self] speed in
            self?.setSantaSpeed(speed)
        }
        statusMenuController.onSelectSantaScale = { [weak self] scale in
            self?.setSantaScale(scale)
        }
        statusMenuController.onToggleRudolph = { [weak self] in
            self?.setRudolphEnabled(!(self?.settings.isRudolphEnabled ?? true))
        }
        statusMenuController.onToggleAccumulation = { [weak self] in
            self?.setAccumulationEnabled(!(self?.settings.isAccumulationEnabled ?? true))
        }
        statusMenuController.onSelectAccumulationSpillMode = { [weak self] mode in
            self?.setAccumulationSpillMode(mode)
        }
        statusMenuController.onSelectAccumulationRate = { [weak self] rate in
            self?.setAccumulationRate(rate)
        }
        statusMenuController.onSelectAccumulationStyle = { [weak self] style in
            self?.setAccumulationStyle(style)
        }
        statusMenuController.onClearAccumulation = { [weak self] in
            self?.clearAccumulation()
        }
        statusMenuController.onSelectOverlayLevel = { [weak self] mode in
            self?.setOverlayLevelMode(mode)
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
            self?.applyWindowSnapshotsToDisplays()
            self?.updateMenuState()
        }
    }

    func start() {
        Diag.log("MacSnowManager.start() begin")
        Diag.log("Calling statusMenuController.configure()...")
        statusMenuController.configure(isSnowEnabled: settings.isSnowEnabled)
        Diag.log("statusMenuController.configure() completed")
        statusMenuController.setDensity(settings.density)
        statusMenuController.setWindStrength(settings.windStrength)
        statusMenuController.setWindDirection(settings.windDirection)
        statusMenuController.setVisualScale(settings.visualScale)
        statusMenuController.setSnowColorMode(settings.snowColorMode)
        statusMenuController.setCelestialEffectsEnabled(settings.isCelestialEffectsEnabled)
        statusMenuController.setAuroraEnabled(settings.isAuroraEnabled)
        statusMenuController.setMoonEnabled(settings.isMoonEnabled)
        statusMenuController.setStarsEnabled(settings.areStarsEnabled)
        statusMenuController.setMeteorsEnabled(settings.areMeteorsEnabled)
        statusMenuController.setBirdsEnabled(settings.areBirdsEnabled)
        statusMenuController.setSantaEnabled(settings.isSantaEnabled)
        statusMenuController.setSceneryEnabled(settings.isSceneryEnabled)
        statusMenuController.setTreesEnabled(settings.areTreesEnabled)
        statusMenuController.setGiftTreeEnabled(settings.isGiftTreeEnabled)
        statusMenuController.setSnowmanEnabled(settings.isSnowmanEnabled)
        statusMenuController.setHouseEnabled(settings.isHouseEnabled)
        statusMenuController.setReindeerEnabled(settings.isReindeerEnabled)
        statusMenuController.setMooseEnabled(settings.isMooseEnabled)
        statusMenuController.setPolarBearEnabled(settings.isPolarBearEnabled)
        statusMenuController.setWinterObjectOptions(settings.winterObjectOptions)
        statusMenuController.setGroundAgentEnabled(settings.isGroundAgentEnabled)
        statusMenuController.setGiftsEnabled(settings.areGiftsEnabled)
        statusMenuController.setObjectAmount(settings.objectAmount)
        statusMenuController.setSantaStyle(settings.santaStyle)
        statusMenuController.setSantaSpeed(settings.santaSpeed)
        statusMenuController.setSantaScale(settings.santaScale)
        statusMenuController.setRudolphEnabled(settings.isRudolphEnabled)
        statusMenuController.setAccumulationEnabled(settings.isAccumulationEnabled)
        statusMenuController.setAccumulationSpillMode(settings.accumulationSpillMode)
        statusMenuController.setAccumulationRate(settings.accumulationRate)
        statusMenuController.setAccumulationStyle(settings.accumulationStyle)
        statusMenuController.setOverlayLevelMode(settings.overlayLevelMode)
        displayDetector.start()
        observePowerNotifications()
        startPowerSaveMonitor()
        rebuildDisplayControllers()
        updateWindowScannerState()
    }

    func stop() {
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        displayDetector.stop()
        powerSaveTimer?.invalidate()
        powerSaveTimer = nil
        windowLayoutScanner.stop()
        displayControllers.forEach { $0.close() }
        displayControllers.removeAll()
    }

    private func setSnowEnabled(_ enabled: Bool) {
        settings.isSnowEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setSnowEnabled(enabled)
        applySettingsToDisplays()
        updateWindowScannerState()
        updateMenuState()
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
        applyWindowSnapshotsToDisplays()
        updateMenuState()
        updateWindowScannerState()
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
        statusMenuController.setWindStrength(windStrength)
        applySettingsToDisplays()
    }

    private func setWindDirection(_ direction: WindDirection) {
        settings.windDirection = direction
        settingsStore.save(settings)
        statusMenuController.setWindDirection(direction)
        applySettingsToDisplays()
    }

    private func setVisualScale(_ scale: VisualScale) {
        settings.visualScale = scale
        settingsStore.save(settings)
        statusMenuController.setVisualScale(scale)
        applySettingsToDisplays()
    }

    private func setSnowColorMode(_ mode: SnowColorMode) {
        settings.snowColorMode = mode
        settingsStore.save(settings)
        statusMenuController.setSnowColorMode(mode)
        applySettingsToDisplays()
    }

    private func setCelestialEffectsEnabled(_ enabled: Bool) {
        settings.isCelestialEffectsEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setCelestialEffectsEnabled(enabled)
        applySettingsToDisplays()
    }

    private func setAuroraEnabled(_ enabled: Bool) { settings.isAuroraEnabled = enabled; settingsStore.save(settings); statusMenuController.setAuroraEnabled(enabled); applySettingsToDisplays() }
    private func setMoonEnabled(_ enabled: Bool) { settings.isMoonEnabled = enabled; settingsStore.save(settings); statusMenuController.setMoonEnabled(enabled); applySettingsToDisplays() }
    private func setStarsEnabled(_ enabled: Bool) { settings.areStarsEnabled = enabled; settingsStore.save(settings); statusMenuController.setStarsEnabled(enabled); applySettingsToDisplays() }
    private func setMeteorsEnabled(_ enabled: Bool) { settings.areMeteorsEnabled = enabled; settingsStore.save(settings); statusMenuController.setMeteorsEnabled(enabled); applySettingsToDisplays() }

    private func setBirdsEnabled(_ enabled: Bool) {
        settings.areBirdsEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setBirdsEnabled(enabled)
        applySettingsToDisplays()
    }

    private func setSantaEnabled(_ enabled: Bool) {
        settings.isSantaEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setSantaEnabled(enabled)
        applySettingsToDisplays()
    }

    private func setSceneryEnabled(_ enabled: Bool) {
        settings.isSceneryEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setSceneryEnabled(enabled)
        applySettingsToDisplays()
    }

    private func setTreesEnabled(_ enabled: Bool) { settings.areTreesEnabled = enabled; settingsStore.save(settings); statusMenuController.setTreesEnabled(enabled); applySettingsToDisplays() }
    private func setGiftTreeEnabled(_ enabled: Bool) { settings.isGiftTreeEnabled = enabled; settingsStore.save(settings); statusMenuController.setGiftTreeEnabled(enabled); applySettingsToDisplays() }
    private func setSnowmanEnabled(_ enabled: Bool) { settings.isSnowmanEnabled = enabled; settingsStore.save(settings); statusMenuController.setSnowmanEnabled(enabled); applySettingsToDisplays() }
    private func setHouseEnabled(_ enabled: Bool) { settings.isHouseEnabled = enabled; settingsStore.save(settings); statusMenuController.setHouseEnabled(enabled); applySettingsToDisplays() }
    private func setReindeerEnabled(_ enabled: Bool) { settings.isReindeerEnabled = enabled; settingsStore.save(settings); statusMenuController.setReindeerEnabled(enabled); applySettingsToDisplays() }
    private func setMooseEnabled(_ enabled: Bool) { settings.isMooseEnabled = enabled; settingsStore.save(settings); statusMenuController.setMooseEnabled(enabled); applySettingsToDisplays() }
    private func setPolarBearEnabled(_ enabled: Bool) { settings.isPolarBearEnabled = enabled; settingsStore.save(settings); statusMenuController.setPolarBearEnabled(enabled); applySettingsToDisplays() }

    private func toggleWinterObject(_ object: WinterObject) {
        let currentValue = settings.winterObjectOptions[object.rawValue] ?? true
        settings.winterObjectOptions[object.rawValue] = !currentValue
        settingsStore.save(settings)
        statusMenuController.setWinterObjectOptions(settings.winterObjectOptions)
        applySettingsToDisplays()
    }

    private func setGroundAgentEnabled(_ enabled: Bool) {
        settings.isGroundAgentEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setGroundAgentEnabled(enabled)
        applySettingsToDisplays()
    }

    private func setGiftsEnabled(_ enabled: Bool) {
        settings.areGiftsEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setGiftsEnabled(enabled)
        applySettingsToDisplays()
    }

    private func setObjectAmount(_ amount: ObjectAmount) {
        settings.objectAmount = amount
        settingsStore.save(settings)
        statusMenuController.setObjectAmount(amount)
        applySettingsToDisplays()
    }

    private func setSantaStyle(_ style: SantaStyle) {
        settings.santaStyle = style
        settingsStore.save(settings)
        statusMenuController.setSantaStyle(style)
        applySettingsToDisplays()
    }

    private func setSantaSpeed(_ speed: SantaSpeed) {
        settings.santaSpeed = speed
        settingsStore.save(settings)
        statusMenuController.setSantaSpeed(speed)
        applySettingsToDisplays()
    }

    private func setSantaScale(_ scale: SantaScale) {
        settings.santaScale = scale
        settingsStore.save(settings)
        statusMenuController.setSantaScale(scale)
        applySettingsToDisplays()
    }

    private func setRudolphEnabled(_ enabled: Bool) {
        settings.isRudolphEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setRudolphEnabled(enabled)
        applySettingsToDisplays()
    }

    private func setAccumulationEnabled(_ enabled: Bool) {
        settings.isAccumulationEnabled = enabled
        settingsStore.save(settings)
        statusMenuController.setAccumulationEnabled(enabled)
        applySettingsToDisplays()
        updateWindowScannerState()
        updateMenuState()
    }

    private func setAccumulationSpillMode(_ mode: AccumulationSpillMode) {
        settings.accumulationSpillMode = mode
        settings.isAccumulationSpillEnabled = mode != .off
        settingsStore.save(settings)
        statusMenuController.setAccumulationSpillMode(mode)
        applySettingsToDisplays()
    }

    private func setAccumulationRate(_ rate: AccumulationRate) {
        settings.accumulationRate = rate
        settingsStore.save(settings)
        statusMenuController.setAccumulationRate(rate)
        applySettingsToDisplays()
    }

    private func setAccumulationStyle(_ style: AccumulationStyle) {
        settings.accumulationStyle = style
        settingsStore.save(settings)
        statusMenuController.setAccumulationStyle(style)
        applySettingsToDisplays()
    }

    private func setOverlayLevelMode(_ mode: OverlayLevelMode) {
        settings.overlayLevelMode = mode
        settingsStore.save(settings)
        statusMenuController.setOverlayLevelMode(mode)
        applySettingsToDisplays()
    }

    private func clearAccumulation() {
        displayControllers.forEach { $0.clearAccumulation() }
    }

    private func toggleDisplay(_ displayID: String) {
        var displaySettings = settings.perDisplay[displayID] ?? MacSnowDisplaySettings()
        displaySettings.isEnabled.toggle()
        settings.perDisplay[displayID] = displaySettings
        settingsStore.save(settings)
        applySettingsToDisplays()
        updateMenuState()
    }

    private func applySettingsToDisplays() {
        for controller in displayControllers {
            let displaySettings = settings.perDisplay[controller.identity.id] ?? MacSnowDisplaySettings()
            let enabled = settings.isSnowEnabled && displaySettings.isEnabled
            controller.apply(
                density: settings.density,
                windStrength: settings.windStrength,
                windDirection: settings.windDirection
            )
            controller.setVisualScale(settings.visualScale)
            controller.setSnowColorMode(settings.snowColorMode)
            controller.setCelestialEffectsEnabled(settings.isCelestialEffectsEnabled)
            controller.setCelestialItemOptions(
                aurora: settings.isAuroraEnabled,
                moon: settings.isMoonEnabled,
                stars: settings.areStarsEnabled,
                meteors: settings.areMeteorsEnabled
            )
            controller.setBirdsEnabled(settings.areBirdsEnabled)
            controller.setSantaEnabled(settings.isSantaEnabled)
            controller.setSceneryEnabled(settings.isSceneryEnabled)
            controller.setSceneryItemOptions(
                trees: settings.areTreesEnabled,
                giftTree: settings.isGiftTreeEnabled,
                snowman: settings.isSnowmanEnabled,
                house: settings.isHouseEnabled,
                reindeer: settings.isReindeerEnabled,
                moose: settings.isMooseEnabled,
                polarBear: settings.isPolarBearEnabled
            )
            controller.setWinterObjectOptions(settings.winterObjectOptions)
            controller.setGroundAgentEnabled(settings.isGroundAgentEnabled)
            controller.setGiftsEnabled(settings.areGiftsEnabled)
            controller.setObjectAmount(settings.objectAmount)
            controller.setSantaOptions(
                style: settings.santaStyle,
                speed: settings.santaSpeed,
                scale: settings.santaScale,
                isRudolphEnabled: settings.isRudolphEnabled
            )
            controller.setOverlayLevelMode(settings.overlayLevelMode)
            controller.setAccumulationEnabled(settings.isAccumulationEnabled)
            controller.setAccumulationSpillMode(settings.accumulationSpillMode)
            controller.setAccumulationRate(settings.accumulationRate)
            controller.setAccumulationStyle(settings.accumulationStyle)
            controller.setSnowEnabled(enabled)
            if !displaySettings.isEnabled {
                controller.clearDisplayContents()
            }
        }
        applyFullscreenPowerSave()
    }

    private func applyWindowSnapshotsToDisplays() {
        guard shouldRunWindowScanner else {
            clearWindowTracking()
            return
        }

        let desktopFrame = NSScreen.screens.reduce(CGRect.null) { partial, screen in
            partial.union(screen.frame)
        }
        guard !desktopFrame.isNull else {
            return
        }

        for controller in displayControllers {
            let displaySettings = settings.perDisplay[controller.identity.id] ?? MacSnowDisplaySettings()
            guard displaySettings.isEnabled else {
                controller.clearWindowTracking()
                continue
            }
            controller.updateWindowSnapshots(scannedWindows, desktopFrame: desktopFrame)
        }
    }

    private var shouldRunWindowScanner: Bool {
        settings.isSnowEnabled
    }

    private func updateWindowScannerState() {
        if shouldRunWindowScanner {
            guard !isWindowScannerRunning else {
                return
            }
            windowLayoutScanner.start()
            isWindowScannerRunning = true
        } else {
            guard isWindowScannerRunning else {
                clearWindowTracking()
                return
            }
            windowLayoutScanner.stop()
            isWindowScannerRunning = false
            clearWindowTracking()
        }
    }

    private func clearWindowTracking() {
        scannedWindows.removeAll()
        displayControllers.forEach { $0.clearWindowTracking() }
    }

    private func startPowerSaveMonitor() {
        powerSaveTimer?.invalidate()
        powerSaveTimer = nil
        applyFullscreenPowerSave()
    }

    private func applyFullscreenPowerSave() {
        for controller in displayControllers {
            let displaySettings = settings.perDisplay[controller.identity.id] ?? MacSnowDisplaySettings()
            let enabled = settings.isSnowEnabled && displaySettings.isEnabled
            controller.setSnowEnabled(enabled)
            if !displaySettings.isEnabled {
                controller.clearDisplayContents()
            }
        }
    }

    private func updateMenuState() {
        let displays = displayControllers.map { controller in
            let displaySettings = settings.perDisplay[controller.identity.id] ?? MacSnowDisplaySettings()
            return (identity: controller.identity, isEnabled: displaySettings.isEnabled)
        }
        statusMenuController.updateDisplays(displays)
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
        windowLayoutScanner.stop()
        isWindowScannerRunning = false
        clearWindowTracking()
        updateMenuState()
    }

    @objc private func handleDidWake() {
        applySettingsToDisplays()
        updateWindowScannerState()
        applyFullscreenPowerSave()
        updateMenuState()
    }
}
