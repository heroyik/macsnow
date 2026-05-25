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

    func apply(density: SnowDensity, windStrength: Double, windDirection: WindDirection) {
        scene.apply(density: density, windStrength: windStrength, windDirection: windDirection)
    }

    func setVisualScale(_ scale: VisualScale) {
        scene.setVisualScale(scale)
    }

    func setSnowColorMode(_ mode: SnowColorMode) {
        scene.setSnowColorMode(mode)
    }

    func setCelestialEffectsEnabled(_ enabled: Bool) {
        scene.setCelestialEffectsEnabled(enabled)
    }

    func setCelestialItemOptions(aurora: Bool, moon: Bool, stars: Bool, meteors: Bool) {
        scene.setCelestialItemOptions(aurora: aurora, moon: moon, stars: stars, meteors: meteors)
    }

    func setBirdsEnabled(_ enabled: Bool) {
        scene.setBirdsEnabled(enabled)
    }

    func setSantaEnabled(_ enabled: Bool) {
        scene.setSantaEnabled(enabled)
    }

    func setSceneryEnabled(_ enabled: Bool) {
        scene.setSceneryEnabled(enabled)
    }

    func setSceneryItemOptions(trees: Bool, giftTree: Bool, snowman: Bool, house: Bool, reindeer: Bool, moose: Bool, polarBear: Bool) {
        scene.setSceneryItemOptions(trees: trees, giftTree: giftTree, snowman: snowman, house: house, reindeer: reindeer, moose: moose, polarBear: polarBear)
    }

    func setGroundAgentEnabled(_ enabled: Bool) {
        scene.setGroundAgentEnabled(enabled)
    }

    func setGiftsEnabled(_ enabled: Bool) {
        scene.setGiftsEnabled(enabled)
    }

    func setObjectAmount(_ amount: ObjectAmount) {
        scene.setObjectAmount(amount)
    }

    func setSantaOptions(style: SantaStyle, speed: SantaSpeed, scale: SantaScale, isRudolphEnabled: Bool) {
        scene.setSantaOptions(style: style, speed: speed, scale: scale, isRudolphEnabled: isRudolphEnabled)
    }

    func setOverlayLevelMode(_ mode: OverlayLevelMode) {
        window.apply(levelMode: mode)
    }

    func setAccumulationEnabled(_ enabled: Bool) {
        scene.setAccumulationEnabled(enabled)
    }

    func setAccumulationSpillMode(_ mode: AccumulationSpillMode) {
        scene.setAccumulationSpillMode(mode)
    }

    func setAccumulationRate(_ rate: AccumulationRate) {
        scene.setAccumulationRate(rate)
    }

    func setAccumulationStyle(_ style: AccumulationStyle) {
        scene.setAccumulationStyle(style)
    }

    func clearAccumulation() {
        scene.clearAccumulation()
    }

    func clearWindowTracking() {
        scene.clearWindowTracking()
    }

    func setEdgeDebugEnabled(_ enabled: Bool) {
        scene.setEdgeDebugEnabled(enabled)
    }

    @discardableResult
    func updateWindowSnapshots(_ snapshots: [WindowSnapshot], desktopFrame: CGRect) -> Int {
        var occluders: [CGRect] = []
        var edges: [SnowCollisionEdge] = []
        let minimumSegmentWidth: CGFloat = 40

        for snapshot in snapshots.sorted(by: { $0.order < $1.order }) {
            let appKitBounds = WindowCoordinateMapper.appKitBounds(for: snapshot, desktopFrame: desktopFrame)
            let visibleBounds = appKitBounds.intersection(screen.frame)
            guard !visibleBounds.isNull, visibleBounds.width >= minimumSegmentWidth else {
                continue
            }

            let topY = appKitBounds.maxY
            let localY = topY - screen.frame.minY
            if localY > 0, localY < screen.frame.height {
                let visibleSegments = visibleTopSegments(
                    xRange: max(visibleBounds.minX, appKitBounds.minX)...min(visibleBounds.maxX, appKitBounds.maxX),
                    topY: topY,
                    occluders: occluders,
                    minimumWidth: minimumSegmentWidth
                )
                for segment in visibleSegments {
                    edges.append(SnowCollisionEdge(
                        xRange: (segment.lowerBound - screen.frame.minX)...(segment.upperBound - screen.frame.minX),
                        y: localY,
                        windowID: snapshot.windowID,
                        order: snapshot.order
                    ))
                }
            }

            occluders.append(visibleBounds)
        }

        scene.updateCollisionEdges(edges)
        return edges.count
    }

    private func visibleTopSegments(
        xRange: ClosedRange<CGFloat>,
        topY: CGFloat,
        occluders: [CGRect],
        minimumWidth: CGFloat
    ) -> [ClosedRange<CGFloat>] {
        var segments = [xRange]
        for occluder in occluders where occluder.minY <= topY && occluder.maxY >= topY {
            segments = segments.flatMap { segment -> [ClosedRange<CGFloat>] in
                let overlapMin = max(segment.lowerBound, occluder.minX)
                let overlapMax = min(segment.upperBound, occluder.maxX)
                guard overlapMax > overlapMin else {
                    return [segment]
                }

                var result: [ClosedRange<CGFloat>] = []
                if overlapMin - segment.lowerBound >= minimumWidth {
                    result.append(segment.lowerBound...overlapMin)
                }
                if segment.upperBound - overlapMax >= minimumWidth {
                    result.append(overlapMax...segment.upperBound)
                }
                return result
            }
        }
        return segments.filter { $0.upperBound - $0.lowerBound >= minimumWidth }
    }

    var isSnowActive: Bool {
        !scene.isPaused
    }
}
