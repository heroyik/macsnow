import AppKit
import CoreGraphics
import Foundation

struct WindowSnapshot: Equatable {
    let ownerName: String
    let bounds: CGRect
}

@MainActor
final class WindowLayoutScanner {
    var onSnapshot: (([WindowSnapshot]) -> Void)?

    private var timer: Timer?
    private let minimumWindowSize: CGFloat = 100

    func start() {
        stop()
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.scan()
            }
        }
        scan()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func scan() {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let rawWindows = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            onSnapshot?([])
            return
        }

        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        let snapshots = rawWindows.compactMap { info -> WindowSnapshot? in
            guard
                let ownerName = info[kCGWindowOwnerName as String] as? String,
                ownerName != appName,
                let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
                let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary),
                bounds.width >= minimumWindowSize,
                bounds.height >= minimumWindowSize
            else {
                return nil
            }

            return WindowSnapshot(ownerName: ownerName, bounds: bounds)
        }

        onSnapshot?(Array(snapshots.prefix(20)))
    }
}
