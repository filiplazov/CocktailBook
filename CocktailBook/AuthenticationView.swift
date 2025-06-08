import LocalAuthentication
import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.dismiss)
    private var dismiss
    @State private var pinInput: String = ""
    @State private var showPinPad: Bool = false
    @State private var biometricErrorMessage: String = ""
    @State private var isAttemptingBiometric: Bool = false

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // App Icon/Logo Area
                VStack(spacing: 16) {
                    Image(systemName: "wineglass.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)

                    Text("CocktailBook")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                // Authentication Content
                VStack(spacing: 24) {
                    if !showPinPad && !isAttemptingBiometric {
                        // Biometric Authentication Section
                        biometricSection
                    } else if showPinPad {
                        // PIN Authentication Section
                        pinSection
                    } else {
                        // Loading state during biometric authentication
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                }

                Spacer()

                // Error message area
                if !biometricErrorMessage.isEmpty {
                    Text(biometricErrorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Wrong attempts display - Reserve space to prevent UI shifting
                Group {
                    if authManager.wrongPinAttempts > 0 && showPinPad {
                        Text("Wrong attempts: \(authManager.wrongPinAttempts)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text(" ")  // Invisible text to reserve space
                            .font(.caption)
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            attemptBiometricAuthentication()
        }
    }

    // MARK: - Biometric Section

    private var biometricSection: some View {
        VStack(spacing: 20) {
            Text("Authentication Required")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Please authenticate to access your cocktail recipes")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Only show biometric button if available
            if authManager.biometricStatus.isAvailable {
                Button(action: {
                    attemptBiometricAuthentication()
                }, label: {
                    HStack(spacing: 12) {
                        Image(systemName: biometricIconName)
                            .font(.title2)
                        Text("Use \(biometricDisplayName)")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                })
            }

            Button(action: {
                showPinPad = true
                biometricErrorMessage = ""
            }, label: {
                Text("Use PIN Instead")
                    .foregroundColor(.gray)
                    .underline()
            })
        }
    }

    // MARK: - PIN Section

    private var pinSection: some View {
        VStack(spacing: 24) {
            Text("Enter PIN")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            // PIN Display
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < pinInput.count ? Color.white : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.vertical, 20)

            // Numeric Keypad
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(1...9, id: \.self) { number in
                    PinButton(text: "\(number)") {
                        addPinDigit("\(number)")
                    }
                }

                // Bottom row: empty, 0, delete
                Color.clear
                    .frame(height: 60)

                PinButton(text: "0") {
                    addPinDigit("0")
                }

                Button(action: {
                    deletePinDigit()
                }, label: {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                })
            }
            .padding(.horizontal, 60)

            // Only show biometric option if available
            if authManager.biometricStatus.isAvailable {
                Button(action: {
                    showPinPad = false
                    biometricErrorMessage = ""
                    attemptBiometricAuthentication()
                }, label: {
                    Text("Use Biometric Instead")
                        .foregroundColor(.gray)
                        .underline()
                })
            }
        }
    }

    // MARK: - Computed Properties

    private var biometricIconName: String {
        let context = LAContext()
        switch context.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.fill"
        }
    }

    private var biometricDisplayName: String {
        let context = LAContext()
        switch context.biometryType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        default:
            return "Biometric"
        }
    }

    // MARK: - Private Methods

    private func addPinDigit(_ digit: String) {
        guard pinInput.count < 4 else { return }

        pinInput += digit

        // Auto-submit when 4 digits entered
        if pinInput.count == 4 {
            checkPin()
        }
    }

    private func deletePinDigit() {
        if !pinInput.isEmpty {
            pinInput.removeLast()
        }
    }

    private func checkPin() {
        let success = authManager.authenticateWithPin(pinInput)

        if success {
            dismiss()
        } else {
            // Clear input and show error
            pinInput = ""

            // Optional: Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }

    private func attemptBiometricAuthentication() {
        guard !isAttemptingBiometric else { return }

        isAttemptingBiometric = true
        biometricErrorMessage = ""

        Task {
            let result = await authManager.authenticateWithBiometrics()

            await MainActor.run {
                isAttemptingBiometric = false

                switch result {
                case .success:
                    dismiss()
                case .biometricFailed(let message):
                    biometricErrorMessage = message
                    showPinPad = true
                case .biometricUnavailable(let message):
                    biometricErrorMessage = message
                    showPinPad = true
                case .cancelled:
                    // User cancelled - show PIN pad
                    showPinPad = true
                case .error(let message):
                    biometricErrorMessage = "Hardware error: \(message)"
                    showPinPad = true
                }
            }
        }
    }
}

// MARK: - PIN Button

private struct PinButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

// MARK: - Preview

#Preview {
    @MainActor
    struct PreviewWrapper: View {
        @StateObject private var authManager = AuthenticationManager()

        var body: some View {
            AuthenticationView(authManager: authManager)
        }
    }

    return PreviewWrapper()
}
