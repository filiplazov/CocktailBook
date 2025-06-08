import Foundation

// MARK: - Authentication Result

public enum AuthenticationResult: Sendable {
    case success
    case biometricFailed(String)
    case biometricUnavailable(String)
    case cancelled
    case error(String)
}
