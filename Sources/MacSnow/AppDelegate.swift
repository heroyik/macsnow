import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var manager: MacSnowManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let manager = MacSnowManager()
        self.manager = manager
        manager.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        manager?.stop()
    }
}
