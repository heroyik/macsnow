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

enum AccumulationRate: String, Codable, CaseIterable {
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

    var growth: CGFloat {
        switch self {
        case .low: 0.3
        case .normal: 0.7
        case .high: 1.2
        }
    }

    var maximumHeight: CGFloat {
        switch self {
        case .low: 10
        case .normal: 18
        case .high: 28
        }
    }
}

enum WindDirection: String, Codable, CaseIterable {
    case left
    case right
    case random

    var title: String {
        switch self {
        case .left: "Right to Left"
        case .right: "Left to Right"
        case .random: "Random"
        }
    }

    var multiplier: Double {
        switch self {
        case .left: -1
        case .right: 1
        case .random: 1
        }
    }
}

enum AccumulationSpillMode: String, Codable, CaseIterable {
    case off
    case overflow
    case avalanche
    case detailed
    case edgeLeak
    case random

    var title: String {
        switch self {
        case .off: "Off"
        case .overflow: "Overflow"
        case .avalanche: "Avalanche"
        case .detailed: "Chunk + Powder"
        case .edgeLeak: "Edge Leak"
        case .random: "Random"
        }
    }
}

enum VisualScale: String, Codable, CaseIterable {
    case compact
    case normal
    case large

    var title: String {
        switch self {
        case .compact: "75%"
        case .normal: "100%"
        case .large: "125%"
        }
    }

    var value: CGFloat {
        switch self {
        case .compact: 0.75
        case .normal: 1.0
        case .large: 1.25
        }
    }
}

enum SnowColorMode: String, Codable, CaseIterable {
    case white
    case cool
    case warm
    case mixed
    case customBlueGold
    case customRoseMint

    var title: String {
        switch self {
        case .white: "White"
        case .cool: "Cool Blue"
        case .warm: "Warm Glow"
        case .mixed: "Mixed"
        case .customBlueGold: "Custom Blue + Gold"
        case .customRoseMint: "Custom Rose + Mint"
        }
    }
}

enum SantaStyle: String, Codable, CaseIterable {
    case random
    case regular
    case medium
    case big
    case alt

    var title: String {
        switch self {
        case .random: "Random"
        case .regular: "Regular"
        case .medium: "Medium"
        case .big: "Big"
        case .alt: "Alt"
        }
    }
}

enum SantaSpeed: String, Codable, CaseIterable {
    case slow
    case normal
    case fast

    var title: String {
        switch self {
        case .slow: "Slow"
        case .normal: "Normal"
        case .fast: "Fast"
        }
    }

    var multiplier: CGFloat {
        switch self {
        case .slow: 0.72
        case .normal: 1.0
        case .fast: 1.36
        }
    }
}

enum SantaScale: String, Codable, CaseIterable {
    case compact
    case normal
    case large

    var title: String {
        switch self {
        case .compact: "75%"
        case .normal: "100%"
        case .large: "125%"
        }
    }

    var multiplier: CGFloat {
        switch self {
        case .compact: 0.75
        case .normal: 1.0
        case .large: 1.25
        }
    }
}

enum OverlayLevelMode: String, Codable, CaseIterable {
    case normal
    case fullscreenFriendly
    case aboveMenu

    var title: String {
        switch self {
        case .normal: "Normal"
        case .fullscreenFriendly: "Fullscreen Friendly"
        case .aboveMenu: "Above Menu"
        }
    }
}

enum AccumulationStyle: String, Codable, CaseIterable {
    case soft
    case layered
    case detailed

    var title: String {
        switch self {
        case .soft: "Soft"
        case .layered: "Layered"
        case .detailed: "Detailed"
        }
    }
}

enum ObjectAmount: String, Codable, CaseIterable {
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

    var multiplier: CGFloat {
        switch self {
        case .low: 0.6
        case .normal: 1.0
        case .high: 1.6
        }
    }
}

enum WinterObject: String, Codable, CaseIterable {
    case igloo
    case icicles
    case iceFishingHole
    case lampPost
    case snowMound
    case icePatch
    case mailbox
    case signPost
    case hotCocoa
    case lantern
    case candyCane
    case winterFence
    case skiLift
    case owl
    case snowAngel
    case snowShovel
    case mittens
    case scarf
    case woolHat
    case wreath
    case stocking
    case bells
    case christmasLights
    case toyTrain
    case chimneySmoke
    case snowballStack
    case frostCrystals
    case penguin
    case arcticFox
    case seal
    case huskySled
    case skier
    case snowboarder
    case wolf
    case rollingSnowball

    enum Group: String, CaseIterable {
        case places = "Places"
        case props = "Props"
        case holiday = "Holiday"
        case animals = "Animals"
        case sports = "Sports"
        case retro = "Retro Toys"
    }

    var title: String {
        switch self {
        case .igloo: "Igloo"
        case .icicles: "Icicles"
        case .iceFishingHole: "Ice Fishing Hole"
        case .lampPost: "Lamp Post"
        case .snowMound: "Snow Mound"
        case .icePatch: "Ice Patch"
        case .mailbox: "Mailbox"
        case .signPost: "Sign Post"
        case .hotCocoa: "Hot Cocoa"
        case .lantern: "Lantern"
        case .candyCane: "Candy Cane"
        case .winterFence: "Winter Fence"
        case .skiLift: "Ski Lift"
        case .owl: "Owl"
        case .snowAngel: "Snow Angel"
        case .snowShovel: "Snow Shovel"
        case .mittens: "Mittens"
        case .scarf: "Scarf"
        case .woolHat: "Wool Hat"
        case .wreath: "Wreath"
        case .stocking: "Stocking"
        case .bells: "Bells"
        case .christmasLights: "Christmas Lights"
        case .toyTrain: "Toy Train"
        case .chimneySmoke: "Chimney Smoke"
        case .snowballStack: "Snowball Stack"
        case .frostCrystals: "Frost Crystals"
        case .penguin: "Penguin"
        case .arcticFox: "Arctic Fox"
        case .seal: "Seal"
        case .huskySled: "Husky Sled"
        case .skier: "Skier"
        case .snowboarder: "Snowboarder"
        case .wolf: "Wolf Silhouette"
        case .rollingSnowball: "Rolling Snowball"
        }
    }

    var group: Group {
        switch self {
        case .igloo, .iceFishingHole, .lampPost, .winterFence, .skiLift:
            .places
        case .snowMound, .icePatch, .mailbox, .signPost, .hotCocoa, .lantern, .snowAngel, .snowShovel, .mittens, .scarf, .woolHat, .frostCrystals:
            .props
        case .candyCane, .wreath, .stocking, .bells, .christmasLights, .chimneySmoke:
            .holiday
        case .penguin, .arcticFox, .seal, .huskySled, .owl, .wolf:
            .animals
        case .skier, .snowboarder:
            .sports
        case .toyTrain, .snowballStack, .rollingSnowball, .icicles:
            .retro
        }
    }

    var isMoving: Bool {
        switch self {
        case .penguin, .arcticFox, .seal, .huskySled, .skier, .snowboarder, .wolf, .rollingSnowball:
            true
        default:
            false
        }
    }

    static var defaultOptions: [String: Bool] {
        Dictionary(uniqueKeysWithValues: allCases.map { ($0.rawValue, true) })
    }
}

struct MacSnowDisplaySettings: Codable {
    var isEnabled: Bool = true
}

struct MacSnowGlobalSettings: Codable {
    var isSnowEnabled: Bool = true
    var density: SnowDensity = .normal
    var windStrength: Double = 0.2
    var windDirection: WindDirection = .right
    var visualScale: VisualScale = .normal
    var snowColorMode: SnowColorMode = .white
    var isCelestialEffectsEnabled: Bool = true
    var isAuroraEnabled: Bool = true
    var isMoonEnabled: Bool = true
    var areStarsEnabled: Bool = true
    var areMeteorsEnabled: Bool = true
    var areBirdsEnabled: Bool = true
    var isSantaEnabled: Bool = true
    var isSceneryEnabled: Bool = true
    var areTreesEnabled: Bool = true
    var isGiftTreeEnabled: Bool = true
    var isSnowmanEnabled: Bool = true
    var isHouseEnabled: Bool = true
    var isReindeerEnabled: Bool = true
    var isMooseEnabled: Bool = true
    var isPolarBearEnabled: Bool = true
    var isGroundAgentEnabled: Bool = true
    var areGiftsEnabled: Bool = true
    var winterObjectOptions: [String: Bool] = WinterObject.defaultOptions
    var objectAmount: ObjectAmount = .normal
    var santaStyle: SantaStyle = .big
    var santaSpeed: SantaSpeed = .normal
    var santaScale: SantaScale = .normal
    var isRudolphEnabled: Bool = true
    var isAccumulationEnabled: Bool = true
    var isAccumulationSpillEnabled: Bool = false
    var accumulationSpillMode: AccumulationSpillMode = .off
    var accumulationRate: AccumulationRate = .normal
    var overlayLevelMode: OverlayLevelMode = .normal
    var accumulationStyle: AccumulationStyle = .layered
    var perDisplay: [String: MacSnowDisplaySettings] = [:]

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSnowEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSnowEnabled) ?? true
        density = try container.decodeIfPresent(SnowDensity.self, forKey: .density) ?? .normal
        windStrength = try container.decodeIfPresent(Double.self, forKey: .windStrength) ?? 0.2
        windDirection = try container.decodeIfPresent(WindDirection.self, forKey: .windDirection) ?? .right
        visualScale = try container.decodeIfPresent(VisualScale.self, forKey: .visualScale) ?? .normal
        snowColorMode = try container.decodeIfPresent(SnowColorMode.self, forKey: .snowColorMode) ?? .white
        isCelestialEffectsEnabled = try container.decodeIfPresent(Bool.self, forKey: .isCelestialEffectsEnabled) ?? true
        isAuroraEnabled = try container.decodeIfPresent(Bool.self, forKey: .isAuroraEnabled) ?? true
        isMoonEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMoonEnabled) ?? true
        areStarsEnabled = try container.decodeIfPresent(Bool.self, forKey: .areStarsEnabled) ?? true
        areMeteorsEnabled = try container.decodeIfPresent(Bool.self, forKey: .areMeteorsEnabled) ?? true
        areBirdsEnabled = try container.decodeIfPresent(Bool.self, forKey: .areBirdsEnabled) ?? true
        isSantaEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSantaEnabled) ?? true
        isSceneryEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSceneryEnabled) ?? true
        areTreesEnabled = try container.decodeIfPresent(Bool.self, forKey: .areTreesEnabled) ?? true
        isGiftTreeEnabled = try container.decodeIfPresent(Bool.self, forKey: .isGiftTreeEnabled) ?? true
        isSnowmanEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSnowmanEnabled) ?? true
        isHouseEnabled = try container.decodeIfPresent(Bool.self, forKey: .isHouseEnabled) ?? true
        isReindeerEnabled = try container.decodeIfPresent(Bool.self, forKey: .isReindeerEnabled) ?? true
        isMooseEnabled = try container.decodeIfPresent(Bool.self, forKey: .isMooseEnabled) ?? true
        isPolarBearEnabled = try container.decodeIfPresent(Bool.self, forKey: .isPolarBearEnabled) ?? true
        isGroundAgentEnabled = try container.decodeIfPresent(Bool.self, forKey: .isGroundAgentEnabled) ?? true
        areGiftsEnabled = try container.decodeIfPresent(Bool.self, forKey: .areGiftsEnabled) ?? true
        let decodedWinterObjectOptions = try container.decodeIfPresent([String: Bool].self, forKey: .winterObjectOptions) ?? [:]
        winterObjectOptions = WinterObject.defaultOptions.merging(decodedWinterObjectOptions) { _, new in new }
        objectAmount = try container.decodeIfPresent(ObjectAmount.self, forKey: .objectAmount) ?? .normal
        santaStyle = try container.decodeIfPresent(SantaStyle.self, forKey: .santaStyle) ?? .big
        santaSpeed = try container.decodeIfPresent(SantaSpeed.self, forKey: .santaSpeed) ?? .normal
        santaScale = try container.decodeIfPresent(SantaScale.self, forKey: .santaScale) ?? .normal
        isRudolphEnabled = try container.decodeIfPresent(Bool.self, forKey: .isRudolphEnabled) ?? true
        isAccumulationEnabled = try container.decodeIfPresent(Bool.self, forKey: .isAccumulationEnabled) ?? true
        isAccumulationSpillEnabled = try container.decodeIfPresent(Bool.self, forKey: .isAccumulationSpillEnabled) ?? false
        accumulationSpillMode = try container.decodeIfPresent(AccumulationSpillMode.self, forKey: .accumulationSpillMode)
            ?? (isAccumulationSpillEnabled ? .detailed : .off)
        accumulationRate = try container.decodeIfPresent(AccumulationRate.self, forKey: .accumulationRate) ?? .normal
        overlayLevelMode = try container.decodeIfPresent(OverlayLevelMode.self, forKey: .overlayLevelMode) ?? .normal
        accumulationStyle = try container.decodeIfPresent(AccumulationStyle.self, forKey: .accumulationStyle) ?? .layered
        perDisplay = try container.decodeIfPresent([String: MacSnowDisplaySettings].self, forKey: .perDisplay) ?? [:]
    }
}

final class SettingsStore {
    private let defaults: UserDefaults
    private let key = "macsnow.settings.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> MacSnowGlobalSettings {
        guard let data = defaults.data(forKey: key) else {
            return MacSnowGlobalSettings()
        }

        do {
            return try JSONDecoder().decode(MacSnowGlobalSettings.self, from: data)
        } catch {
            return MacSnowGlobalSettings()
        }
    }

    func save(_ settings: MacSnowGlobalSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}
