import Foundation

// MARK: - Biometric Authentication Status

public enum BiometricAuthenticationStatus: Sendable {
    case available
    case unavailable(reason: String)
    case notEnrolled
    case hardwareUnavailable
    case error(String)

    var displayText: String {
        switch self {
        case .available:
            return "Available"
        case .unavailable(let reason):
            return "Unavailable: \(reason)"
        case .notEnrolled:
            return "Not Set Up"
        case .hardwareUnavailable:
            return "Hardware Unavailable"
        case .error(let message):
            return "Error: \(message)"
        }
    }

    var isAvailable: Bool {
        if case .available = self {
            return true
        }
        return false
    }
}
