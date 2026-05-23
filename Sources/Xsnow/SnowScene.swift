import AppKit
import SpriteKit

@MainActor
final class SnowScene: SKScene {
    private let emitter = SKEmitterNode()
    private var density: SnowDensity = .normal
    private var windStrength = 0.2

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0, y: 0)
        configureEmitter()
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func setSnowEnabled(_ enabled: Bool) {
        isPaused = !enabled
        emitter.particleBirthRate = enabled ? currentBirthRate : 0
    }

    func apply(density: SnowDensity, windStrength: Double) {
        self.density = density
        self.windStrength = windStrength
        emitter.xAcceleration = 40 * windStrength
        emitter.particleBirthRate = isPaused ? 0 : currentBirthRate
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        positionEmitter()
    }

    private var baseBirthRate: CGFloat {
        max(80, size.width / 18)
    }

    private var currentBirthRate: CGFloat {
        baseBirthRate * density.birthRateMultiplier
    }

    private func configureEmitter() {
        emitter.particleTexture = makeSnowTexture()
        emitter.particleBirthRate = currentBirthRate
        emitter.particleLifetime = 12
        emitter.particleLifetimeRange = 4
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 16
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 45
        emitter.yAcceleration = -18
        emitter.xAcceleration = 40 * windStrength
        emitter.particleAlpha = 0.85
        emitter.particleAlphaRange = 0.25
        emitter.particleScale = 0.8
        emitter.particleScaleRange = 0.5
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .alpha
        positionEmitter()
        addChild(emitter)
    }

    private func positionEmitter() {
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 12)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        emitter.particleBirthRate = isPaused ? 0 : currentBirthRate
    }

    private func makeSnowTexture() -> SKTexture {
        let image = NSImage(size: NSSize(width: 6, height: 6))
        image.lockFocus()
        NSColor.white.setFill()
        NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 6, height: 6)).fill()
        image.unlockFocus()
        return SKTexture(image: image)
    }
}
