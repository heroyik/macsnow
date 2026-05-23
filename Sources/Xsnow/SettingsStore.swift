import AppKit
import Foundation

enum SnowDensity: String, Codable, CaseIterable {
    case low
    case normal
    case high

    var title: String {
        switch self {
        case .low: "Low"
        case .normal: "Normal"
        case .high: "High"
        }
    }

    var birthRateMultiplier: CGFloat {
        switch self {
        case .low: 0.45
        case .normal: 1.0
        case .high: 1.7
        }
    }
}

struct XsnowDisplaySettings: Codable {
    var isEnabled: Bool = true
}

struct XsnowGlobalSettings: Codable {
    var isSnowEnabled: Bool = true
    var density: SnowDensity = .normal
    var windStrength: Double = 0.2
    var perDisplay: [String: XsnowDisplaySettings] = [:]
}

final class SettingsStore {
    private let defaults: UserDefaults
    private let key = "xsnow.settings.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> XsnowGlobalSettings {
        guard let data = defaults.data(forKey: key) else {
            return XsnowGlobalSettings()
        }

        do {
            return try JSONDecoder().decode(XsnowGlobalSettings.self, from: data)
        } catch {
            return XsnowGlobalSettings()
        }
    }

    func save(_ settings: XsnowGlobalSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}
