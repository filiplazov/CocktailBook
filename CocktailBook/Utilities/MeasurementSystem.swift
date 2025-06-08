import Foundation

// MARK: - Measurement System

public enum MeasurementSystem: String, CaseIterable, Sendable {
    case imperial = "imperial"
    case metric = "metric"
    
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
    
    private let userDefaults: UserDefaultsProtocol
    
    // MARK: - User Defaults Keys
    
    private enum UserDefaultsKeys {
        static let measurementSystem = "measurementSystem"
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
        }
    }
} 