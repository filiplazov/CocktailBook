import Foundation
import LocalAuthentication

// MARK: - Local Authentication Protocol

protocol LocalAuthenticationProtocol {
    func canEvaluatePolicy(_ policy: LAPolicy, error: inout NSError?) -> Bool
    func evaluatePolicy(
        _ policy: LAPolicy,
        localizedReason: String
    ) async throws -> Bool
    var biometryType: LABiometryType { get }
}

// MARK: - Concrete Implementation

final class LocalAuthenticationService: LocalAuthenticationProtocol {
    private let context = LAContext()

    func canEvaluatePolicy(_ policy: LAPolicy, error: inout NSError?) -> Bool {
        context.canEvaluatePolicy(policy, error: &error)
    }

    func evaluatePolicy(
        _ policy: LAPolicy,
        localizedReason: String
    ) async throws -> Bool {
        try await context.evaluatePolicy(policy, localizedReason: localizedReason)
    }

    var biometryType: LABiometryType {
        context.biometryType
    }
}
