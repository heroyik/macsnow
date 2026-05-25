import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var manager: MacSnowManager?

    func startIfNeeded() {
        guard manager == nil else {
            return
        }
        let manager = MacSnowManager()
        self.manager = manager
        manager.start()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        startIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        manager?.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
