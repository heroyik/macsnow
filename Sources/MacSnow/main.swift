import AppKit

Diag.log("main.swift start")
Diag.log("Bundle path: \(Bundle.main.bundlePath)")
Diag.log("Activation policy before: \(NSApplication.shared.activationPolicy().rawValue)")

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.setActivationPolicy(.accessory)
Diag.log("Activation policy after: \(app.activationPolicy().rawValue)")

app.finishLaunching()
Diag.log("finishLaunching completed")

DispatchQueue.main.async {
    Diag.log("DispatchQueue.main.async fired")
    delegate.startIfNeeded()
    Diag.log("startIfNeeded completed from async block")
}

Diag.log("About to call app.run()")
app.run()
Diag.log("app.run() returned (should not happen)")
