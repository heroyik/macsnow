import CoreGraphics

struct WindowCoordinateMapper {
    static func appKitBounds(for snapshot: WindowSnapshot, desktopFrame: CGRect) -> CGRect {
        CGRect(
            x: snapshot.bounds.origin.x,
            y: desktopFrame.maxY - snapshot.bounds.maxY,
            width: snapshot.bounds.width,
            height: snapshot.bounds.height
        )
    }

    static func collisionEdge(
        for snapshot: WindowSnapshot,
        screenFrame: CGRect,
        desktopFrame: CGRect,
        minimumWidth: CGFloat = 40
    ) -> SnowCollisionEdge? {
        let appKitBounds = appKitBounds(for: snapshot, desktopFrame: desktopFrame)
        let visibleBounds = appKitBounds.intersection(screenFrame)
        guard !visibleBounds.isNull, visibleBounds.width >= minimumWidth else {
            return nil
        }

        let y = visibleBounds.maxY - screenFrame.minY
        guard y > 0, y < screenFrame.height else {
            return nil
        }

        return SnowCollisionEdge(
            xRange: (visibleBounds.minX - screenFrame.minX)...(visibleBounds.maxX - screenFrame.minX),
            y: y,
            windowID: snapshot.windowID,
            order: snapshot.order
        )
    }
}
