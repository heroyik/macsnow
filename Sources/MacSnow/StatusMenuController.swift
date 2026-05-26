import AppKit

@MainActor
final class StatusMenuController {
    var onToggleSnow: (() -> Void)?
    var onSelectDensity: ((SnowDensity) -> Void)?
    var onAdjustWind: ((Double) -> Void)?
    var onSelectWindDirection: ((WindDirection) -> Void)?
    var onSelectVisualScale: ((VisualScale) -> Void)?
    var onSelectSnowColorMode: ((SnowColorMode) -> Void)?
    var onToggleCelestialEffects: (() -> Void)?
    var onToggleAurora: (() -> Void)?
    var onToggleMoon: (() -> Void)?
    var onToggleStars: (() -> Void)?
    var onToggleMeteors: (() -> Void)?
    var onToggleBirds: (() -> Void)?
    var onToggleSanta: (() -> Void)?
    var onToggleScenery: (() -> Void)?
    var onToggleTrees: (() -> Void)?
    var onToggleGiftTree: (() -> Void)?
    var onToggleSnowman: (() -> Void)?
    var onToggleHouse: (() -> Void)?
    var onToggleReindeer: (() -> Void)?
    var onToggleMoose: (() -> Void)?
    var onTogglePolarBear: (() -> Void)?
    var onToggleGroundAgent: (() -> Void)?
    var onToggleGifts: (() -> Void)?
    var onSelectObjectAmount: ((ObjectAmount) -> Void)?
    var onSelectSantaStyle: ((SantaStyle) -> Void)?
    var onSelectSantaSpeed: ((SantaSpeed) -> Void)?
    var onSelectSantaScale: ((SantaScale) -> Void)?
    var onToggleRudolph: (() -> Void)?
    var onToggleAccumulation: (() -> Void)?
    var onSelectAccumulationSpillMode: ((AccumulationSpillMode) -> Void)?
    var onSelectAccumulationRate: ((AccumulationRate) -> Void)?
    var onSelectAccumulationStyle: ((AccumulationStyle) -> Void)?
    var onClearAccumulation: (() -> Void)?
    var onSelectOverlayLevel: ((OverlayLevelMode) -> Void)?
    var onToggleDisplay: ((String) -> Void)?
    var onQuit: (() -> Void)?

    private let statusItem = NSStatusBar.system.statusItem(withLength: 22)
    private let menu = NSMenu()
    private let toggleItem = NSMenuItem(title: "Snow: On", action: #selector(toggleSnow), keyEquivalent: "")
    private let visibilityMenu = NSMenu()
    private let celestialEffectsItem = NSMenuItem(title: "Celestial Effects", action: #selector(toggleCelestialEffects), keyEquivalent: "")
    private let auroraItem = NSMenuItem(title: "Aurora", action: #selector(toggleAurora), keyEquivalent: "")
    private let moonItem = NSMenuItem(title: "Moon", action: #selector(toggleMoon), keyEquivalent: "")
    private let starsItem = NSMenuItem(title: "Stars", action: #selector(toggleStars), keyEquivalent: "")
    private let meteorsItem = NSMenuItem(title: "Meteors", action: #selector(toggleMeteors), keyEquivalent: "")
    private let birdsItem = NSMenuItem(title: "Birds", action: #selector(toggleBirds), keyEquivalent: "")
    private let santaItem = NSMenuItem(title: "Santa Flight", action: #selector(toggleSanta), keyEquivalent: "")
    private let sceneryItem = NSMenuItem(title: "Scenery", action: #selector(toggleScenery), keyEquivalent: "")
    private let treesItem = NSMenuItem(title: "Trees", action: #selector(toggleTrees), keyEquivalent: "")
    private let giftTreeItem = NSMenuItem(title: "Gift Tree", action: #selector(toggleGiftTree), keyEquivalent: "")
    private let snowmanItem = NSMenuItem(title: "Snowman", action: #selector(toggleSnowman), keyEquivalent: "")
    private let houseItem = NSMenuItem(title: "House", action: #selector(toggleHouse), keyEquivalent: "")
    private let reindeerItem = NSMenuItem(title: "Reindeer", action: #selector(toggleReindeer), keyEquivalent: "")
    private let mooseItem = NSMenuItem(title: "Moose", action: #selector(toggleMoose), keyEquivalent: "")
    private let polarBearItem = NSMenuItem(title: "Polar Bear", action: #selector(togglePolarBear), keyEquivalent: "")
    private let groundAgentItem = NSMenuItem(title: "Ground Agent", action: #selector(toggleGroundAgent), keyEquivalent: "")
    private let giftsItem = NSMenuItem(title: "Gifts", action: #selector(toggleGifts), keyEquivalent: "")
    private let rudolphItem = NSMenuItem(title: "Rudolph", action: #selector(toggleRudolph), keyEquivalent: "")
    private let accumulationItem = NSMenuItem(title: "Window Accumulation", action: #selector(toggleAccumulation), keyEquivalent: "")
    private let clearAccumulationItem = NSMenuItem(title: "Clear Accumulation", action: #selector(clearAccumulation), keyEquivalent: "")
    private let versionItem = NSMenuItem(title: "Version -", action: nil, keyEquivalent: "")
    private let densityMenu = NSMenu()
    private let visualScaleMenu = NSMenu()
    private let snowColorMenu = NSMenu()
    private let windStrengthMenu = NSMenu()
    private let windDirectionMenu = NSMenu()
    private let santaStyleMenu = NSMenu()
    private let santaSpeedMenu = NSMenu()
    private let santaScaleMenu = NSMenu()
    private let objectAmountMenu = NSMenu()
    private let accumulationSpillMenu = NSMenu()
    private let accumulationRateMenu = NSMenu()
    private let accumulationStyleMenu = NSMenu()
    private let overlayLevelMenu = NSMenu()
    private let displaysMenu = NSMenu()
    private var displayItemsByID: [String: NSMenuItem] = [:]

    func configure(isSnowEnabled: Bool) {
        Diag.log("configure() called, isSnowEnabled=\(isSnowEnabled)")
        statusItem.autosaveName = "local.macsnow.statusItem"
        Diag.log("configure() - statusItem=\(statusItem), button=\(String(describing: statusItem.button)), length=\(statusItem.length)")

        Diag.log("configure() - statusItem type: \(type(of: statusItem))")
        if let btn = statusItem.button {
            Diag.log("configure() - button type: \(type(of: btn)), alpha=\(btn.alphaValue), enabled=\(btn.isEnabled), hidden=\(btn.isHidden)")
            Self.applyStatusImage(to: btn)
            Diag.log("configure() - status image applied immediately")
        }

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

        let visualScaleRoot = NSMenuItem(title: "Visual Scale", action: nil, keyEquivalent: "")
        menu.addItem(visualScaleRoot)
        menu.setSubmenu(visualScaleMenu, for: visualScaleRoot)
        for scale in VisualScale.allCases {
            let item = NSMenuItem(title: scale.title, action: #selector(selectVisualScale(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = scale.rawValue
            visualScaleMenu.addItem(item)
        }

        let snowColorRoot = NSMenuItem(title: "Snow Color", action: nil, keyEquivalent: "")
        menu.addItem(snowColorRoot)
        menu.setSubmenu(snowColorMenu, for: snowColorRoot)
        for mode in SnowColorMode.allCases {
            let item = NSMenuItem(title: mode.title, action: #selector(selectSnowColorMode(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode.rawValue
            snowColorMenu.addItem(item)
        }

        let windStrengthRoot = NSMenuItem(title: "Wind Strength", action: nil, keyEquivalent: "")
        menu.addItem(windStrengthRoot)
        menu.setSubmenu(windStrengthMenu, for: windStrengthRoot)
        for option in [0.0, 0.2, 0.5] {
            let item = NSMenuItem(title: windTitle(for: option), action: #selector(selectWind(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = option
            windStrengthMenu.addItem(item)
        }

        let windDirectionRoot = NSMenuItem(title: "Wind Direction", action: nil, keyEquivalent: "")
        menu.addItem(windDirectionRoot)
        menu.setSubmenu(windDirectionMenu, for: windDirectionRoot)
        for direction in WindDirection.allCases {
            let item = NSMenuItem(title: direction.title, action: #selector(selectWindDirection(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = direction.rawValue
            windDirectionMenu.addItem(item)
        }

        let visibilityRoot = NSMenuItem(title: "Visibility", action: nil, keyEquivalent: "")
        menu.addItem(visibilityRoot)
        menu.setSubmenu(visibilityMenu, for: visibilityRoot)

        celestialEffectsItem.target = self
        visibilityMenu.addItem(celestialEffectsItem)
        for item in [auroraItem, moonItem, starsItem, meteorsItem] {
            item.target = self
            visibilityMenu.addItem(item)
        }

        birdsItem.target = self
        visibilityMenu.addItem(birdsItem)

        santaItem.target = self
        visibilityMenu.addItem(santaItem)

        let santaStyleRoot = NSMenuItem(title: "Santa Style", action: nil, keyEquivalent: "")
        menu.addItem(santaStyleRoot)
        menu.setSubmenu(santaStyleMenu, for: santaStyleRoot)
        for style in SantaStyle.allCases {
            let item = NSMenuItem(title: style.title, action: #selector(selectSantaStyle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = style.rawValue
            santaStyleMenu.addItem(item)
        }

        let santaSpeedRoot = NSMenuItem(title: "Santa Speed", action: nil, keyEquivalent: "")
        menu.addItem(santaSpeedRoot)
        menu.setSubmenu(santaSpeedMenu, for: santaSpeedRoot)
        for speed in SantaSpeed.allCases {
            let item = NSMenuItem(title: speed.title, action: #selector(selectSantaSpeed(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = speed.rawValue
            santaSpeedMenu.addItem(item)
        }

        let santaScaleRoot = NSMenuItem(title: "Santa Scale", action: nil, keyEquivalent: "")
        menu.addItem(santaScaleRoot)
        menu.setSubmenu(santaScaleMenu, for: santaScaleRoot)
        for scale in SantaScale.allCases {
            let item = NSMenuItem(title: scale.title, action: #selector(selectSantaScale(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = scale.rawValue
            santaScaleMenu.addItem(item)
        }

        rudolphItem.target = self
        visibilityMenu.addItem(rudolphItem)

        sceneryItem.target = self
        visibilityMenu.addItem(sceneryItem)
        for item in [treesItem, giftTreeItem, snowmanItem, houseItem, reindeerItem, mooseItem, polarBearItem] {
            item.target = self
            visibilityMenu.addItem(item)
        }

        groundAgentItem.target = self
        visibilityMenu.addItem(groundAgentItem)

        giftsItem.target = self
        visibilityMenu.addItem(giftsItem)

        let objectAmountRoot = NSMenuItem(title: "Object Amount", action: nil, keyEquivalent: "")
        menu.addItem(objectAmountRoot)
        menu.setSubmenu(objectAmountMenu, for: objectAmountRoot)
        for amount in ObjectAmount.allCases {
            let item = NSMenuItem(title: amount.title, action: #selector(selectObjectAmount(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = amount.rawValue
            objectAmountMenu.addItem(item)
        }

        let accumulationSpillRoot = NSMenuItem(title: "Spill Options", action: nil, keyEquivalent: "")
        menu.addItem(accumulationSpillRoot)
        menu.setSubmenu(accumulationSpillMenu, for: accumulationSpillRoot)
        for mode in AccumulationSpillMode.allCases {
            let item = NSMenuItem(title: mode.title, action: #selector(selectAccumulationSpillMode(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode.rawValue
            accumulationSpillMenu.addItem(item)
        }

        let accumulationRateRoot = NSMenuItem(title: "Accumulation Rate", action: nil, keyEquivalent: "")
        menu.addItem(accumulationRateRoot)
        menu.setSubmenu(accumulationRateMenu, for: accumulationRateRoot)
        for rate in AccumulationRate.allCases {
            let item = NSMenuItem(title: rate.title, action: #selector(selectAccumulationRate(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = rate.rawValue
            accumulationRateMenu.addItem(item)
        }

        let accumulationStyleRoot = NSMenuItem(title: "Accumulation Style", action: nil, keyEquivalent: "")
        menu.addItem(accumulationStyleRoot)
        menu.setSubmenu(accumulationStyleMenu, for: accumulationStyleRoot)
        for style in AccumulationStyle.allCases {
            let item = NSMenuItem(title: style.title, action: #selector(selectAccumulationStyle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = style.rawValue
            accumulationStyleMenu.addItem(item)
        }

        accumulationItem.target = self
        visibilityMenu.addItem(accumulationItem)

        clearAccumulationItem.target = self
        menu.addItem(clearAccumulationItem)

        let overlayLevelRoot = NSMenuItem(title: "Overlay Level", action: nil, keyEquivalent: "")
        menu.addItem(overlayLevelRoot)
        menu.setSubmenu(overlayLevelMenu, for: overlayLevelRoot)
        for mode in OverlayLevelMode.allCases {
            let item = NSMenuItem(title: mode.title, action: #selector(selectOverlayLevel(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode.rawValue
            overlayLevelMenu.addItem(item)
        }

        let displaysRoot = NSMenuItem(title: "Displays", action: nil, keyEquivalent: "")
        menu.addItem(displaysRoot)
        menu.setSubmenu(displaysMenu, for: displaysRoot)

        versionItem.isEnabled = false
        versionItem.title = "Version \(appVersion)"
        menu.addItem(versionItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit MacSnow", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        setSnowEnabled(isSnowEnabled)

        // NSSceneStatusItem on macOS 26+ silently discards button properties
        // set before its scene is fully active. Defer to after scene activation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self, let button = self.statusItem.button else { return }
            Diag.log("deferred0.2: title='\(button.title)', image=\(button.image != nil)")
            Self.applyStatusImage(to: button)
            Diag.log("deferred0.2: re-applied")
        }
    }

    func setSnowEnabled(_ enabled: Bool) {
        toggleItem.title = enabled ? "Snow: On" : "Snow: Off"
        toggleItem.state = enabled ? .on : .off
    }

    func setDensity(_ density: SnowDensity) {
        for item in densityMenu.items {
            item.state = (item.representedObject as? String) == density.rawValue ? .on : .off
        }
    }

    func setWindStrength(_ windStrength: Double) {
        for item in windStrengthMenu.items {
            item.state = (item.representedObject as? Double) == windStrength ? .on : .off
        }
    }

    func setWindDirection(_ direction: WindDirection) {
        for item in windDirectionMenu.items {
            item.state = (item.representedObject as? String) == direction.rawValue ? .on : .off
        }
    }

    func setVisualScale(_ scale: VisualScale) {
        for item in visualScaleMenu.items {
            item.state = (item.representedObject as? String) == scale.rawValue ? .on : .off
        }
    }

    func setSnowColorMode(_ mode: SnowColorMode) {
        for item in snowColorMenu.items {
            item.state = (item.representedObject as? String) == mode.rawValue ? .on : .off
        }
    }

    func setCelestialEffectsEnabled(_ enabled: Bool) {
        celestialEffectsItem.state = enabled ? .on : .off
        for item in [auroraItem, moonItem, starsItem, meteorsItem] {
            item.isEnabled = enabled
        }
    }

    func setAuroraEnabled(_ enabled: Bool) { auroraItem.state = enabled ? .on : .off }
    func setMoonEnabled(_ enabled: Bool) { moonItem.state = enabled ? .on : .off }
    func setStarsEnabled(_ enabled: Bool) { starsItem.state = enabled ? .on : .off }
    func setMeteorsEnabled(_ enabled: Bool) { meteorsItem.state = enabled ? .on : .off }

    func setBirdsEnabled(_ enabled: Bool) {
        birdsItem.state = enabled ? .on : .off
    }

    func setSantaEnabled(_ enabled: Bool) {
        santaItem.state = enabled ? .on : .off
        rudolphItem.isEnabled = enabled
        for item in santaStyleMenu.items {
            item.isEnabled = enabled
        }
        for item in santaSpeedMenu.items {
            item.isEnabled = enabled
        }
        for item in santaScaleMenu.items {
            item.isEnabled = enabled
        }
    }

    func setSantaStyle(_ style: SantaStyle) {
        for item in santaStyleMenu.items {
            item.state = (item.representedObject as? String) == style.rawValue ? .on : .off
        }
    }

    func setSantaSpeed(_ speed: SantaSpeed) {
        for item in santaSpeedMenu.items {
            item.state = (item.representedObject as? String) == speed.rawValue ? .on : .off
        }
    }

    func setSantaScale(_ scale: SantaScale) {
        for item in santaScaleMenu.items {
            item.state = (item.representedObject as? String) == scale.rawValue ? .on : .off
        }
    }

    func setRudolphEnabled(_ enabled: Bool) {
        rudolphItem.state = enabled ? .on : .off
    }

    func setSceneryEnabled(_ enabled: Bool) {
        sceneryItem.state = enabled ? .on : .off
        for item in [treesItem, giftTreeItem, snowmanItem, houseItem, reindeerItem, mooseItem, polarBearItem] {
            item.isEnabled = enabled
        }
    }

    func setTreesEnabled(_ enabled: Bool) { treesItem.state = enabled ? .on : .off }
    func setGiftTreeEnabled(_ enabled: Bool) { giftTreeItem.state = enabled ? .on : .off }
    func setSnowmanEnabled(_ enabled: Bool) { snowmanItem.state = enabled ? .on : .off }
    func setHouseEnabled(_ enabled: Bool) { houseItem.state = enabled ? .on : .off }
    func setReindeerEnabled(_ enabled: Bool) { reindeerItem.state = enabled ? .on : .off }
    func setMooseEnabled(_ enabled: Bool) { mooseItem.state = enabled ? .on : .off }
    func setPolarBearEnabled(_ enabled: Bool) { polarBearItem.state = enabled ? .on : .off }
    func setGroundAgentEnabled(_ enabled: Bool) {
        groundAgentItem.state = enabled ? .on : .off
    }

    func setGiftsEnabled(_ enabled: Bool) {
        giftsItem.state = enabled ? .on : .off
    }

    func setObjectAmount(_ amount: ObjectAmount) {
        for item in objectAmountMenu.items {
            item.state = (item.representedObject as? String) == amount.rawValue ? .on : .off
        }
    }

    func setAccumulationEnabled(_ enabled: Bool) {
        accumulationItem.state = enabled ? .on : .off
        clearAccumulationItem.isEnabled = enabled
        for item in accumulationSpillMenu.items {
            item.isEnabled = enabled
        }
        for item in accumulationRateMenu.items {
            item.isEnabled = enabled
        }
        for item in accumulationStyleMenu.items {
            item.isEnabled = enabled
        }
    }

    func setAccumulationSpillMode(_ mode: AccumulationSpillMode) {
        for item in accumulationSpillMenu.items {
            item.state = (item.representedObject as? String) == mode.rawValue ? .on : .off
        }
    }

    func setAccumulationRate(_ rate: AccumulationRate) {
        for item in accumulationRateMenu.items {
            item.state = (item.representedObject as? String) == rate.rawValue ? .on : .off
        }
    }

    func setAccumulationStyle(_ style: AccumulationStyle) {
        for item in accumulationStyleMenu.items {
            item.state = (item.representedObject as? String) == style.rawValue ? .on : .off
        }
    }

    func setOverlayLevelMode(_ mode: OverlayLevelMode) {
        for item in overlayLevelMenu.items {
            item.state = (item.representedObject as? String) == mode.rawValue ? .on : .off
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

    @objc private func selectWindDirection(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let direction = WindDirection(rawValue: rawValue)
        else {
            return
        }
        onSelectWindDirection?(direction)
    }

    @objc private func selectVisualScale(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let scale = VisualScale(rawValue: rawValue)
        else {
            return
        }
        onSelectVisualScale?(scale)
    }

    @objc private func selectSnowColorMode(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let mode = SnowColorMode(rawValue: rawValue)
        else {
            return
        }
        onSelectSnowColorMode?(mode)
    }

    @objc private func toggleCelestialEffects() {
        onToggleCelestialEffects?()
    }

    @objc private func toggleAurora() { onToggleAurora?() }
    @objc private func toggleMoon() { onToggleMoon?() }
    @objc private func toggleStars() { onToggleStars?() }
    @objc private func toggleMeteors() { onToggleMeteors?() }

    @objc private func toggleBirds() {
        onToggleBirds?()
    }

    @objc private func toggleSanta() {
        onToggleSanta?()
    }

    @objc private func toggleScenery() {
        onToggleScenery?()
    }

    @objc private func toggleTrees() { onToggleTrees?() }
    @objc private func toggleGiftTree() { onToggleGiftTree?() }
    @objc private func toggleSnowman() { onToggleSnowman?() }
    @objc private func toggleHouse() { onToggleHouse?() }
    @objc private func toggleReindeer() { onToggleReindeer?() }
    @objc private func toggleMoose() { onToggleMoose?() }
    @objc private func togglePolarBear() { onTogglePolarBear?() }
    @objc private func toggleGroundAgent() {
        onToggleGroundAgent?()
    }

    @objc private func toggleGifts() {
        onToggleGifts?()
    }

    @objc private func selectObjectAmount(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let amount = ObjectAmount(rawValue: rawValue)
        else {
            return
        }
        onSelectObjectAmount?(amount)
    }

    @objc private func selectSantaStyle(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let style = SantaStyle(rawValue: rawValue)
        else {
            return
        }
        onSelectSantaStyle?(style)
    }

    @objc private func selectSantaSpeed(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let speed = SantaSpeed(rawValue: rawValue)
        else {
            return
        }
        onSelectSantaSpeed?(speed)
    }

    @objc private func selectSantaScale(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let scale = SantaScale(rawValue: rawValue)
        else {
            return
        }
        onSelectSantaScale?(scale)
    }

    @objc private func toggleRudolph() {
        onToggleRudolph?()
    }

    @objc private func toggleAccumulation() {
        onToggleAccumulation?()
    }

    @objc private func selectAccumulationSpillMode(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let mode = AccumulationSpillMode(rawValue: rawValue)
        else {
            return
        }
        onSelectAccumulationSpillMode?(mode)
    }

    @objc private func selectAccumulationRate(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let rate = AccumulationRate(rawValue: rawValue)
        else {
            return
        }
        onSelectAccumulationRate?(rate)
    }

    @objc private func selectAccumulationStyle(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let style = AccumulationStyle(rawValue: rawValue)
        else {
            return
        }
        onSelectAccumulationStyle?(style)
    }

    @objc private func clearAccumulation() {
        onClearAccumulation?()
    }

    @objc private func selectOverlayLevel(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let mode = OverlayLevelMode(rawValue: rawValue)
        else {
            return
        }
        onSelectOverlayLevel?(mode)
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

    private static func makeStatusImage() -> NSImage {
        if let image = NSImage(systemSymbolName: "snowflake", accessibilityDescription: "MacSnow") {
            image.isTemplate = true
            image.size = NSSize(width: 16, height: 16)
            return image
        }

        let image = NSImage(size: NSSize(width: 16, height: 16))
        image.lockFocus()
        NSColor.labelColor.setStroke()
        let center = NSPoint(x: 8, y: 8)
        for angle in stride(from: CGFloat(0), to: .pi, by: .pi / 3) {
            let dx = cos(angle) * 6
            let dy = sin(angle) * 6
            let path = NSBezierPath()
            path.move(to: NSPoint(x: center.x - dx, y: center.y - dy))
            path.line(to: NSPoint(x: center.x + dx, y: center.y + dy))
            path.lineWidth = 1.4
            path.stroke()
        }
        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private static func applyStatusImage(to button: NSStatusBarButton) {
        button.image = makeStatusImage()
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyDown
        button.toolTip = "MacSnow"
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? AppVersion.current
    }
}
