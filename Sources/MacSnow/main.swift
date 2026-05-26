import AppKit
import Darwin

private final class SingleInstanceLock {
    private var fileDescriptor: CInt = -1

    func acquire() -> Bool {
        let path = "/tmp/local.macsnow.prototype.lock"
        fileDescriptor = open(path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard fileDescriptor >= 0 else {
            Diag.log("Single instance lock open failed: errno=\(errno)")
            return true
        }

        if flock(fileDescriptor, LOCK_EX | LOCK_NB) != 0 {
            terminateExistingInstance()

            guard waitForLock(timeout: 5.0) else {
                Diag.log("Existing MacSnow instance did not terminate; refusing to start a second instance")
                close(fileDescriptor)
                fileDescriptor = -1
                return false
            }
        }

        writeCurrentPID()
        return true
    }

    deinit {
        if fileDescriptor >= 0 {
            ftruncate(fileDescriptor, 0)
            flock(fileDescriptor, LOCK_UN)
            close(fileDescriptor)
        }
    }

    private func terminateExistingInstance() {
        if let pid = readExistingPID() {
            terminate(pid: pid)
            return
        }

        let pids = runningMacSnowPIDs()
        guard !pids.isEmpty else {
            Diag.log("Existing MacSnow instance lock has no PID; waiting for lock release")
            return
        }

        Diag.log("Existing MacSnow lock has no PID; terminating discovered MacSnow pids=\(pids)")
        for pid in pids {
            terminate(pid: pid)
        }
    }

    private func terminate(pid: pid_t) {
        guard pid != getpid() else {
            return
        }

        guard isMacSnowProcess(pid) else {
            Diag.log("Lock PID \(pid) is not MacSnow; waiting for lock release")
            return
        }

        Diag.log("Terminating existing MacSnow instance pid=\(pid)")
        if kill(pid, SIGTERM) != 0 && errno != ESRCH {
            Diag.log("SIGTERM failed for existing MacSnow instance pid=\(pid), errno=\(errno)")
            return
        }

        let deadline = Date().addingTimeInterval(3.0)
        while Date() < deadline {
            if kill(pid, 0) != 0 && errno == ESRCH {
                return
            }
            usleep(100_000)
        }

        Diag.log("Existing MacSnow instance pid=\(pid) did not exit after SIGTERM; sending SIGKILL")
        if kill(pid, SIGKILL) != 0 && errno != ESRCH {
            Diag.log("SIGKILL failed for existing MacSnow instance pid=\(pid), errno=\(errno)")
        }
    }

    private func waitForLock(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if flock(fileDescriptor, LOCK_EX | LOCK_NB) == 0 {
                return true
            }
            usleep(100_000)
        }
        return false
    }

    private func readExistingPID() -> pid_t? {
        lseek(fileDescriptor, 0, SEEK_SET)

        var buffer = [UInt8](repeating: 0, count: 32)
        let count = read(fileDescriptor, &buffer, buffer.count)
        guard count > 0 else {
            return nil
        }

        let data = Data(buffer.prefix(count))
        guard
            let string = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            let pid = pid_t(string),
            pid > 0
        else {
            return nil
        }

        return pid
    }

    private func writeCurrentPID() {
        let pidString = "\(getpid())\n"
        let bytes = Array(pidString.utf8)
        lseek(fileDescriptor, 0, SEEK_SET)
        ftruncate(fileDescriptor, 0)
        _ = write(fileDescriptor, bytes, bytes.count)
    }

    private func runningMacSnowPIDs() -> [pid_t] {
        let maximumPID = max(1, proc_listallpids(nil, 0))
        var pids = [pid_t](repeating: 0, count: Int(maximumPID))
        let bytes = proc_listallpids(&pids, Int32(pids.count * MemoryLayout<pid_t>.stride))
        guard bytes > 0 else {
            return []
        }

        let count = bytes / Int32(MemoryLayout<pid_t>.stride)
        return pids.prefix(Int(count))
            .filter { $0 > 0 && $0 != getpid() && isMacSnowProcess($0) }
    }

    private func isMacSnowProcess(_ pid: pid_t) -> Bool {
        var pathBuffer = [CChar](repeating: 0, count: 4096)
        let byteCount = proc_pidpath(pid, &pathBuffer, UInt32(pathBuffer.count))
        guard byteCount > 0 else {
            return false
        }

        let pathBytes = pathBuffer.prefix(Int(byteCount)).map { UInt8(bitPattern: $0) }
        let path = String(decoding: pathBytes, as: UTF8.self)
        return URL(fileURLWithPath: path).lastPathComponent == "MacSnow"
    }
}

Diag.log("main.swift start")
Diag.log("Bundle path: \(Bundle.main.bundlePath)")
Diag.log("Activation policy before: \(NSApplication.shared.activationPolicy().rawValue)")

private let instanceLock = SingleInstanceLock()
guard instanceLock.acquire() else {
    exit(EXIT_SUCCESS)
}

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
