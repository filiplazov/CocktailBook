import Foundation

// MARK: - Measurement System

public enum MeasurementSystem: String, CaseIterable, Sendable {
    case imperial
    case metric

    var displayName: String {
        switch self {
        case .imperial:
            return "Imperial"
        case .metric:
            return "Metric"
        }
    }
}

// MARK: - Settings Manager

@MainActor
final class SettingsManager: ObservableObject {
    @Published var measurementSystem: MeasurementSystem {
        didSet {
            userDefaults.set(measurementSystem.rawValue, forKey: UserDefaultsKeys.measurementSystem)
        }
    }

    @Published var useFakeAPI: Bool {
        didSet {
            userDefaults.set(useFakeAPI, forKey: UserDefaultsKeys.useFakeAPI)
        }
    }

    private let userDefaults: UserDefaultsProtocol

    // MARK: - User Defaults Keys

    private enum UserDefaultsKeys {
        static let measurementSystem = "measurementSystem"
        static let useFakeAPI = "useFakeAPI"
    }

    // MARK: - Initialization

    init(userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.userDefaults = userDefaults

        // Load saved measurement system or default to imperial
        if let savedSystemString = userDefaults.object(forKey: UserDefaultsKeys.measurementSystem) as? String,
           let savedSystem = MeasurementSystem(rawValue: savedSystemString) {
            self.measurementSystem = savedSystem
        } else {
            self.measurementSystem = .imperial
            // Save the default value to UserDefaults
            userDefaults.set(MeasurementSystem.imperial.rawValue, forKey: UserDefaultsKeys.measurementSystem)
        }

        // Load saved fake API setting or default to false
        self.useFakeAPI = userDefaults.object(forKey: UserDefaultsKeys.useFakeAPI) as? Bool ?? false
        if userDefaults.object(forKey: UserDefaultsKeys.useFakeAPI) == nil {
            // Save the default value to UserDefaults
            userDefaults.set(false, forKey: UserDefaultsKeys.useFakeAPI)
        }
    }
}
