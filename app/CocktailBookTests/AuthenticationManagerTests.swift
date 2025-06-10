// swiftlint:disable type_body_length
@testable import CocktailBook
import LocalAuthentication
import XCTest

final class AuthenticationManagerTests: XCTestCase {
    private var authManager: AuthenticationManager!
    private var mockUserDefaults: MockUserDefaults!
    private var mockLocalAuthService: MockLocalAuthenticationService!

    @MainActor
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        mockLocalAuthService = MockLocalAuthenticationService()
        authManager = AuthenticationManager(
            userDefaults: mockUserDefaults,
            localAuthService: mockLocalAuthService
        )
    }

    override func tearDown() {
        authManager = nil
        mockUserDefaults = nil
        mockLocalAuthService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    @MainActor
    func testInitialization_WithNoSavedPreference_DefaultsToDisabled() {
        // Given & When
        let manager = AuthenticationManager(
            userDefaults: mockUserDefaults,
            localAuthService: mockLocalAuthService
        )

        // Then
        XCTAssertFalse(manager.isAuthenticationEnabled)
        XCTAssertFalse(manager.isAuthenticated)
        XCTAssertEqual(manager.wrongPinAttempts, 0)
    }

    @MainActor
    func testInitialization_WithSavedEnabledPreference_LoadsSavedValue() {
        // Given
        mockUserDefaults.set(true, forKey: "authenticationEnabled")

        // When
        let manager = AuthenticationManager(
            userDefaults: mockUserDefaults,
            localAuthService: mockLocalAuthService
        )

        // Then
        XCTAssertTrue(manager.isAuthenticationEnabled)
    }

    @MainActor
    func testInitialization_WithSavedDisabledPreference_LoadsSavedValue() {
        // Given
        mockUserDefaults.set(false, forKey: "authenticationEnabled")

        // When
        let manager = AuthenticationManager(
            userDefaults: mockUserDefaults,
            localAuthService: mockLocalAuthService
        )

        // Then
        XCTAssertFalse(manager.isAuthenticationEnabled)
    }

    // MARK: - Settings Persistence Tests

    @MainActor
    func testAuthenticationEnabled_WhenToggled_PersistsToUserDefaults() {
        // Given
        XCTAssertFalse(authManager.isAuthenticationEnabled)

        // When
        authManager.isAuthenticationEnabled = true

        // Then
        let savedValue = mockUserDefaults.object(forKey: "authenticationEnabled") as? Bool
        XCTAssertTrue(savedValue == true)
    }

    @MainActor
    func testAuthenticationEnabled_WhenToggledMultipleTimes_PersistsLatestValue() {
        // Given
        authManager.isAuthenticationEnabled = true
        authManager.isAuthenticationEnabled = false

        // When
        authManager.isAuthenticationEnabled = true

        // Then
        let savedValue = mockUserDefaults.object(forKey: "authenticationEnabled") as? Bool
        XCTAssertTrue(savedValue == true)
    }

    // MARK: - PIN Authentication Tests

    @MainActor
    func testAuthenticateWithPin_WithCorrectPin_ReturnsTrue() {
        // Given
        let correctPin = "0000"

        // When
        let success = authManager.authenticateWithPin(correctPin)

        // Then
        XCTAssertTrue(success)
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertEqual(authManager.wrongPinAttempts, 0)
    }

    @MainActor
    func testAuthenticateWithPin_WithIncorrectPin_ReturnsFalse() {
        // Given
        let incorrectPin = "1234"

        // When
        let success = authManager.authenticateWithPin(incorrectPin)

        // Then
        XCTAssertFalse(success)
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertEqual(authManager.wrongPinAttempts, 1)
    }

    @MainActor
    func testAuthenticateWithPin_WithMultipleIncorrectAttempts_TracksWrongAttempts() {
        // Given
        let incorrectPin = "1234"

        // When
        _ = authManager.authenticateWithPin(incorrectPin)
        _ = authManager.authenticateWithPin(incorrectPin)
        _ = authManager.authenticateWithPin(incorrectPin)

        // Then
        XCTAssertEqual(authManager.wrongPinAttempts, 3)
        XCTAssertFalse(authManager.isAuthenticated)
    }

    @MainActor
    func testAuthenticateWithPin_AfterWrongAttempts_CorrectPinResetsCounter() {
        // Given
        _ = authManager.authenticateWithPin("1234") // Wrong
        _ = authManager.authenticateWithPin("5678") // Wrong
        XCTAssertEqual(authManager.wrongPinAttempts, 2)

        // When
        let success = authManager.authenticateWithPin("0000") // Correct

        // Then
        XCTAssertTrue(success)
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertEqual(authManager.wrongPinAttempts, 0)
    }

    @MainActor
    func testAuthenticateWithPin_WithEmptyPin_ReturnsFalse() {
        // Given
        let emptyPin = ""

        // When
        let success = authManager.authenticateWithPin(emptyPin)

        // Then
        XCTAssertFalse(success)
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertEqual(authManager.wrongPinAttempts, 1)
    }

    @MainActor
    func testAuthenticateWithPin_WithShortPin_ReturnsFalse() {
        // Given
        let shortPin = "123"

        // When
        let success = authManager.authenticateWithPin(shortPin)

        // Then
        XCTAssertFalse(success)
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertEqual(authManager.wrongPinAttempts, 1)
    }

    @MainActor
    func testAuthenticateWithPin_WithLongPin_ReturnsFalse() {
        // Given
        let longPin = "12345"

        // When
        let success = authManager.authenticateWithPin(longPin)

        // Then
        XCTAssertFalse(success)
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertEqual(authManager.wrongPinAttempts, 1)
    }

    // MARK: - Session Management Tests

    @MainActor
    func testResetAuthenticationForNewSession_ResetsAllAuthenticationState() {
        // Given
        _ = authManager.authenticateWithPin("0000") // Authenticate successfully
        _ = authManager.authenticateWithPin("1234") // Add some wrong attempts
        XCTAssertTrue(authManager.isAuthenticated)
        XCTAssertGreaterThan(authManager.wrongPinAttempts, 0)

        // When
        authManager.resetAuthenticationForNewSession()

        // Then
        XCTAssertFalse(authManager.isAuthenticated)
        XCTAssertEqual(authManager.wrongPinAttempts, 0)
    }

    @MainActor
    func testResetAuthenticationForNewSession_DoesNotAffectSettings() {
        // Given
        authManager.isAuthenticationEnabled = true
        _ = authManager.authenticateWithPin("0000")

        // When
        authManager.resetAuthenticationForNewSession()

        // Then
        XCTAssertTrue(authManager.isAuthenticationEnabled) // Setting preserved
        XCTAssertFalse(authManager.isAuthenticated) // Authentication state reset
    }

    // MARK: - Biometric Status Tests

    @MainActor
    func testBiometricStatus_InitialState_IsUnavailable() {
        // Given & When
        let manager = AuthenticationManager(
            userDefaults: mockUserDefaults,
            localAuthService: mockLocalAuthService
        )

        // Then
        XCTAssertFalse(manager.biometricStatus.isAvailable)
    }

    func testBiometricStatus_DisplayText_ReturnsCorrectFormat() {
        // Given
        let availableStatus = BiometricAuthenticationStatus.available
        let unavailableStatus = BiometricAuthenticationStatus.unavailable(reason: "Not enrolled")
        let notEnrolledStatus = BiometricAuthenticationStatus.notEnrolled
        let hardwareUnavailableStatus = BiometricAuthenticationStatus.hardwareUnavailable
        let errorStatus = BiometricAuthenticationStatus.error("Test error")

        // When & Then
        XCTAssertEqual(availableStatus.displayText, "Available")
        XCTAssertEqual(unavailableStatus.displayText, "Unavailable: Not enrolled")
        XCTAssertEqual(notEnrolledStatus.displayText, "Not Set Up")
        XCTAssertEqual(hardwareUnavailableStatus.displayText, "Hardware Unavailable")
        XCTAssertEqual(errorStatus.displayText, "Error: Test error")
    }

    func testBiometricStatus_IsAvailable_OnlyTrueForAvailableCase() {
        // Given
        let availableStatus = BiometricAuthenticationStatus.available
        let unavailableStatus = BiometricAuthenticationStatus.unavailable(reason: "Test")
        let notEnrolledStatus = BiometricAuthenticationStatus.notEnrolled
        let hardwareUnavailableStatus = BiometricAuthenticationStatus.hardwareUnavailable
        let errorStatus = BiometricAuthenticationStatus.error("Test")

        // When & Then
        XCTAssertTrue(availableStatus.isAvailable)
        XCTAssertFalse(unavailableStatus.isAvailable)
        XCTAssertFalse(notEnrolledStatus.isAvailable)
        XCTAssertFalse(hardwareUnavailableStatus.isAvailable)
        XCTAssertFalse(errorStatus.isAvailable)
    }

    // MARK: - Authentication Result Tests

    func testAuthenticationResult_AllCases_CanBeCreated() {
        // Given & When
        let successResult = AuthenticationResult.success
        let biometricFailedResult = AuthenticationResult.biometricFailed("Failed")
        let biometricUnavailableResult = AuthenticationResult.biometricUnavailable("Unavailable")
        let cancelledResult = AuthenticationResult.cancelled
        let errorResult = AuthenticationResult.error("Error")

        // Then - Just verify they can be created without crashing
        XCTAssertNotNil(successResult)
        XCTAssertNotNil(biometricFailedResult)
        XCTAssertNotNil(biometricUnavailableResult)
        XCTAssertNotNil(cancelledResult)
        XCTAssertNotNil(errorResult)
    }

    // MARK: - Edge Cases Tests

    @MainActor
    func testAuthenticateWithPin_CaseSensitivity_IsExact() {
        // Given
        let correctPin = "0000"
        let pinWithSpaces = " 0000 "
        let pinWithLeadingZeros = "0000"

        // When & Then
        XCTAssertTrue(authManager.authenticateWithPin(correctPin))

        // Reset for next test
        authManager.resetAuthenticationForNewSession()

        XCTAssertFalse(authManager.authenticateWithPin(pinWithSpaces))
        XCTAssertTrue(authManager.authenticateWithPin(pinWithLeadingZeros))
    }

    @MainActor
    func testPersistence_WithInvalidData_HandlesGracefully() {
        // Given
        mockUserDefaults.set("invalid_boolean", forKey: "authenticationEnabled")

        // When
        let manager = AuthenticationManager(
            userDefaults: mockUserDefaults,
            localAuthService: mockLocalAuthService
        )

        // Then - Should default to false
        XCTAssertFalse(manager.isAuthenticationEnabled)
    }

    // MARK: - Biometric Authentication Tests

    @MainActor
    func testAuthenticateWithBiometrics_WithSuccessfulAuthentication_ReturnsSuccess() async {
        // Given
        mockLocalAuthService.configureBiometricSuccess(biometryType: .faceID)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .success = result {
            XCTAssertTrue(authManager.isAuthenticated)
            XCTAssertEqual(authManager.wrongPinAttempts, 0)
            XCTAssertGreaterThanOrEqual(mockLocalAuthService.canEvaluatePolicyCallCount, 1)
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 1)
            XCTAssertEqual(mockLocalAuthService.lastLocalizedReason, "Authenticate to access your cocktail recipes")
        } else {
            XCTFail("Expected success result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenBiometricUnavailable_ReturnsUnavailable() async {
        // Given
        let error = LAError(.biometryNotAvailable)
        mockLocalAuthService.configureBiometricUnavailable(error: error)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .biometricUnavailable(let message) = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertFalse(message.isEmpty, "Error message should not be empty")
            XCTAssertGreaterThanOrEqual(mockLocalAuthService.canEvaluatePolicyCallCount, 1)
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 0)
        } else {
            XCTFail("Expected biometricUnavailable result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenUserCancels_ReturnsCancelled() async {
        // Given
        let error = LAError(.userCancel)
        mockLocalAuthService.configureBiometricFailure(error: error)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .cancelled = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertGreaterThanOrEqual(mockLocalAuthService.canEvaluatePolicyCallCount, 1)
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 1)
        } else {
            XCTFail("Expected cancelled result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenBiometryNotEnrolled_ReturnsUnavailable() async {
        // Given
        let error = LAError(.biometryNotEnrolled)
        mockLocalAuthService.configureBiometricUnavailable(error: error)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .biometricUnavailable(let message) = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertFalse(message.isEmpty, "Error message should not be empty")
            XCTAssertGreaterThanOrEqual(mockLocalAuthService.canEvaluatePolicyCallCount, 1)
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 0)
        } else {
            XCTFail("Expected biometricUnavailable result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenBiometryLockout_ReturnsFailed() async {
        // Given
        let error = LAError(.biometryLockout)
        mockLocalAuthService.configureBiometricFailure(error: error)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .biometricFailed(let message) = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertTrue(message.contains("Too many failed attempts"))
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 1)
        } else {
            XCTFail("Expected biometricFailed result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenSystemCancel_ReturnsCancelled() async {
        // Given
        let error = LAError(.systemCancel)
        mockLocalAuthService.configureBiometricFailure(error: error)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .cancelled = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 1)
        } else {
            XCTFail("Expected cancelled result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenAppCancel_ReturnsCancelled() async {
        // Given
        let error = LAError(.appCancel)
        mockLocalAuthService.configureBiometricFailure(error: error)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .cancelled = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 1)
        } else {
            XCTFail("Expected cancelled result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenGenericLAError_ReturnsFailed() async {
        // Given
        let error = LAError(.authenticationFailed)
        mockLocalAuthService.configureBiometricFailure(error: error)

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .biometricFailed(let message) = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertFalse(message.isEmpty)
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 1)
        } else {
            XCTFail("Expected biometricFailed result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WhenNonLAError_ReturnsError() async {
        // Given
        struct CustomError: Error, LocalizedError {
            var errorDescription: String? {
                "Custom error"
            }
        }
        mockLocalAuthService.configureBiometricSuccess()
        mockLocalAuthService.mockEvaluateError = CustomError()

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .error(let message) = result {
            XCTAssertFalse(authManager.isAuthenticated)
            XCTAssertTrue(message.contains("Custom error"))
            XCTAssertEqual(mockLocalAuthService.evaluatePolicyCallCount, 1)
        } else {
            XCTFail("Expected error result, got \(result)")
        }
    }

    @MainActor
    func testAuthenticateWithBiometrics_WithPreviousWrongPinAttempts_ResetsAttemptsOnSuccess() async {
        // Given
        _ = authManager.authenticateWithPin("1234") // Wrong PIN
        _ = authManager.authenticateWithPin("5678") // Wrong PIN
        XCTAssertEqual(authManager.wrongPinAttempts, 2)

        mockLocalAuthService.configureBiometricSuccess()

        // When
        let result = await authManager.authenticateWithBiometrics()

        // Then
        if case .success = result {
            XCTAssertTrue(authManager.isAuthenticated)
            XCTAssertEqual(authManager.wrongPinAttempts, 0)
        } else {
            XCTFail("Expected success result, got \(result)")
        }
    }

    // MARK: - Biometric Status Update Tests

    @MainActor
    func testCheckBiometricAvailability_WithAvailableBiometrics_UpdatesStatus() async {
        // Given
        mockLocalAuthService.configureBiometricSuccess(biometryType: .touchID)

        // When
        await authManager.checkBiometricAvailability()

        // Then
        XCTAssertTrue(authManager.biometricStatus.isAvailable)
        if case .available = authManager.biometricStatus {
            // Success
        } else {
            XCTFail("Expected available status, got \(authManager.biometricStatus)")
        }
    }

    @MainActor
    func testCheckBiometricAvailability_WithUnavailableBiometrics_UpdatesStatus() async {
        // Given
        let error = LAError(.biometryNotAvailable)
        mockLocalAuthService.configureBiometricUnavailable(error: error)

        // When
        await authManager.checkBiometricAvailability()

        // Then
        XCTAssertFalse(authManager.biometricStatus.isAvailable)
        if case .hardwareUnavailable = authManager.biometricStatus {
            // Success
        } else {
            XCTFail("Expected hardwareUnavailable status, got \(authManager.biometricStatus)")
        }
    }

    @MainActor
    func testCheckBiometricAvailability_WithNotEnrolledBiometrics_UpdatesStatus() async {
        // Given
        let error = LAError(.biometryNotEnrolled)
        mockLocalAuthService.configureBiometricUnavailable(error: error)

        // When
        await authManager.checkBiometricAvailability()

        // Then
        XCTAssertFalse(authManager.biometricStatus.isAvailable)
        if case .notEnrolled = authManager.biometricStatus {
            // Success
        } else {
            XCTFail("Expected notEnrolled status, got \(authManager.biometricStatus)")
        }
    }
}
