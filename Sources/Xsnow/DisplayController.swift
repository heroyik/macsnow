import AppKit
import SpriteKit

@MainActor
final class DisplayController {
    private let screen: NSScreen
    let identity: DisplayIdentity
    private let window: OverlayWindow
    private let scene: SnowScene

    init(screen: NSScreen, identity: DisplayIdentity) {
        self.screen = screen
        self.identity = identity
        window = OverlayWindow(screen: screen)
        scene = SnowScene(size: screen.frame.size)

        let view = SKView(frame: NSRect(origin: .zero, size: screen.frame.size))
        view.allowsTransparency = true
        view.ignoresSiblingOrder = true
        view.presentScene(scene)

        window.contentView = view
    }

    func show() {
        window.setFrame(screen.frame, display: true)
        window.orderFrontRegardless()
    }

    func close() {
        window.orderOut(nil)
        window.close()
    }

    func setSnowEnabled(_ enabled: Bool) {
        scene.setSnowEnabled(enabled)
    }

    func apply(density: SnowDensity, windStrength: Double) {
        scene.apply(density: density, windStrength: windStrength)
    }

    var isSnowActive: Bool {
        !scene.isPaused
    }
}
