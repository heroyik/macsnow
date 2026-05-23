import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var manager: XsnowManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let manager = XsnowManager()
        self.manager = manager
        manager.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        manager?.stop()
    }
}
