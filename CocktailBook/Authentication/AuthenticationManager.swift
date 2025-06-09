import Foundation
import LocalAuthentication
import SwiftUI

// MARK: - Authentication Manager

@MainActor
final class AuthenticationManager: ObservableObject {
    // MARK: - Published Properties

    @Published var isAuthenticationEnabled: Bool {
        didSet {
            userDefaults.set(isAuthenticationEnabled, forKey: UserDefaultsKeys.authenticationEnabled)
        }
    }

    @Published var biometricStatus: BiometricAuthenticationStatus = .unavailable(reason: "Not checked")
    @Published var isAuthenticated: Bool = false
    @Published var wrongPinAttempts: Int = 0

    // MARK: - Private Properties

    private let userDefaults: UserDefaultsProtocol
    private let localAuthService: LocalAuthenticationProtocol

    // MARK: - Configuration

    private let correctPin = "0000" // Configurable for testing
    private let maxPinAttempts = Int.max // No limit for now

    // MARK: - User Defaults Keys

    private enum UserDefaultsKeys {
        static let authenticationEnabled = "authenticationEnabled"
    }

    // MARK: - Initialization

    init(
        userDefaults: UserDefaultsProtocol = UserDefaults.standard,
        localAuthService: LocalAuthenticationProtocol = LocalAuthenticationService()
    ) {
        self.userDefaults = userDefaults
        self.localAuthService = localAuthService

        // Load saved authentication preference (default: false)
        self.isAuthenticationEnabled = userDefaults
            .object(forKey: UserDefaultsKeys.authenticationEnabled) as? Bool ?? false

        // Check biometric status on initialization
        Task {
            await updateBiometricStatus()
        }
    }

    // MARK: - Public Methods

    func checkBiometricAvailability() async {
        await updateBiometricStatus()
    }

    func authenticateWithBiometrics() async -> AuthenticationResult {
        var error: NSError?

        // Check if biometric authentication is available
        guard localAuthService.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                return .biometricUnavailable(error.localizedDescription)
            }
            return .biometricUnavailable("Biometric authentication not available")
        }

        do {
            let success = try await localAuthService.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your cocktail recipes"
            )

            if success {
                isAuthenticated = true
                wrongPinAttempts = 0 // Reset on successful authentication
                return .success
            } else {
                return .biometricFailed("Authentication failed")
            }
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel:
                return .cancelled
            case .biometryNotAvailable:
                return .biometricUnavailable("Biometric authentication not available")
            case .biometryNotEnrolled:
                return .biometricUnavailable("No biometric credentials enrolled")
            case .biometryLockout:
                return .biometricFailed("Too many failed attempts. Use PIN instead.")
            default:
                return .biometricFailed(error.localizedDescription)
            }
        } catch {
            return .error(error.localizedDescription)
        }
    }

    func authenticateWithPin(_ pin: String) -> Bool {
        if pin == correctPin {
            isAuthenticated = true
            wrongPinAttempts = 0
            return true
        } else {
            wrongPinAttempts += 1
            return false
        }
    }

    func resetAuthenticationForNewSession() {
        isAuthenticated = false
        wrongPinAttempts = 0
    }

    func requestBiometricPermission() async {
        // Check current status to determine best action
        var error: NSError?

        // If biometric is completely unavailable (no hardware), just open settings
        if !localAuthService.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if let error = error {
                switch error.code {
                case LAError.biometryNotAvailable.rawValue:
                    // Hardware not available - go straight to settings
                    await MainActor.run {
                        openSystemSettings()
                    }
                    return
                case LAError.biometryNotEnrolled.rawValue:
                    // Not enrolled - go to settings to enroll
                    await MainActor.run {
                        openSystemSettings()
                    }
                    return
                default:
                    // Other errors - try authentication first, then settings
                    break
                }
            }
        }

        // Try biometric authentication to trigger permission dialog if needed
        let result = await authenticateWithBiometrics()

        // Update status after attempt
        await updateBiometricStatus()

        // If authentication succeeded, we're done
        if case .success = result {
            return
        }

        // If failed, open system settings
        await MainActor.run {
            openSystemSettings()
        }
    }

    func openSystemSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Private Methods

private extension AuthenticationManager {
    func updateBiometricStatus() async {
        var error: NSError?

        let canEvaluate = localAuthService.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        if canEvaluate {
            biometricStatus = .available
        } else if let error = error {
            switch error.code {
            case LAError.biometryNotAvailable.rawValue:
                biometricStatus = .hardwareUnavailable
            case LAError.biometryNotEnrolled.rawValue:
                biometricStatus = .notEnrolled
            default:
                biometricStatus = .unavailable(reason: error.localizedDescription)
            }
        } else {
            biometricStatus = .unavailable(reason: "Unknown error")
        }
    }
}

// MARK: - Testing Configuration

extension AuthenticationManager {
    // For testing purposes - allows configurable PIN
    func setTestPin(_ pin: String) {
        // This would be used in tests to configure different PINs
        // For now, we keep the PIN as a private constant
        // In the future, this could be implemented for testing
    }
}
