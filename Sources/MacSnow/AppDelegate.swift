import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var manager: MacSnowManager?

    func startIfNeeded() {
        Diag.log("AppDelegate.startIfNeeded() called")
        guard manager == nil else {
            Diag.log("startIfNeeded() - manager already exists, returning")
            return
        }
        Diag.log("Creating MacSnowManager...")
        let manager = MacSnowManager()
        self.manager = manager
        Diag.log("Calling manager.start()...")
        manager.start()
        Diag.log("manager.start() completed")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Diag.log("applicationDidFinishLaunching fired - not starting yet, waiting for run loop")
        // Intentionally not calling startIfNeeded() here.
        // On macOS 26+, status items are scene-based (NSSceneStatusItem) and need
        // the run loop to be active before they can register properly.
        // startIfNeeded() is called from DispatchQueue.main.async in main.swift,
        // which runs after the run loop starts.
    }

    func applicationWillTerminate(_ notification: Notification) {
        manager?.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
