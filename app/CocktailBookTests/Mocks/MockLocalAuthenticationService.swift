@testable import CocktailBook
import Foundation
import LocalAuthentication

// MARK: - Mock Local Authentication Service

final class MockLocalAuthenticationService: LocalAuthenticationProtocol {
    // MARK: - Configuration Properties

    var mockCanEvaluateResult: Bool = false
    var mockCanEvaluateError: NSError?
    var mockEvaluateResult: Bool = false
    var mockEvaluateError: Error?
    var mockBiometryType: LABiometryType = .none

    // MARK: - Call Tracking

    private(set) var canEvaluatePolicyCallCount = 0
    private(set) var evaluatePolicyCallCount = 0
    private(set) var lastPolicy: LAPolicy?
    private(set) var lastLocalizedReason: String?

    // MARK: - Protocol Implementation

    func canEvaluatePolicy(_ policy: LAPolicy, error: inout NSError?) -> Bool {
        canEvaluatePolicyCallCount += 1
        lastPolicy = policy

        if let mockError = mockCanEvaluateError {
            error = mockError
        }

        return mockCanEvaluateResult
    }

    func evaluatePolicy(
        _ policy: LAPolicy,
        localizedReason: String
    ) async throws -> Bool {
        evaluatePolicyCallCount += 1
        lastPolicy = policy
        lastLocalizedReason = localizedReason

        if let mockError = mockEvaluateError {
            throw mockError
        }

        return mockEvaluateResult
    }

    var biometryType: LABiometryType {
        mockBiometryType
    }

    // MARK: - Test Helper Methods

    func reset() {
        canEvaluatePolicyCallCount = 0
        evaluatePolicyCallCount = 0
        lastPolicy = nil
        lastLocalizedReason = nil
        mockCanEvaluateResult = false
        mockCanEvaluateError = nil
        mockEvaluateResult = false
        mockEvaluateError = nil
        mockBiometryType = .none
    }

    func configureBiometricSuccess(biometryType: LABiometryType = .faceID) {
        mockCanEvaluateResult = true
        mockCanEvaluateError = nil
        mockEvaluateResult = true
        mockEvaluateError = nil
        mockBiometryType = biometryType
    }

    func configureBiometricFailure(error: LAError) {
        mockCanEvaluateResult = true
        mockCanEvaluateError = nil
        mockEvaluateResult = false
        mockEvaluateError = error
    }

    func configureBiometricUnavailable(error: LAError) {
        mockCanEvaluateResult = false
        mockCanEvaluateError = error as NSError
        mockEvaluateResult = false
        mockEvaluateError = nil
    }
}
