import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var authManager: AuthenticationManager
    @Environment(\.dismiss)
    private var dismiss
    @State private var showingAuthenticationView = false

    var body: some View {
        NavigationView {
            List {
                // MARK: - Security Section
                Section {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Toggle("Authentication Required", isOn: $authManager.isAuthenticationEnabled)
                            .onChange(of: authManager.isAuthenticationEnabled) { _, newValue in
                                if newValue {
                                    // When authentication is enabled, immediately verify the user can authenticate
                                    showingAuthenticationView = true
                                }
                            }
                    }

                    if authManager.isAuthenticationEnabled {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Biometric Authentication")
                                Text(authManager.biometricStatus.displayText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if !authManager.biometricStatus.isAvailable {
                                Button("Settings") {
                                    Task {
                                        await authManager.requestBiometricPermission()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                } header: {
                    Text("Security")
                } footer: {
                    Text("When enabled, you'll need to authenticate with biometrics or PIN every time you " +
                         "open the app. Use the Settings button to configure Face ID or Touch ID if unavailable.")
                }

                // MARK: - Measurement Section
                Section {
                    HStack {
                        Image(systemName: "ruler")
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                        Picker("Measurement System", selection: $settingsManager.measurementSystem) {
                            ForEach(MeasurementSystem.allCases, id: \.self) { system in
                                Text(system.displayName).tag(system)
                            }
                        }
                        .pickerStyle(NavigationLinkPickerStyle())
                    }
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("Choose between Imperial (oz, fl oz) and Metric (ml, cl) measurements for " +
                         "cocktail ingredients.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // Refresh biometric status when settings appear
                Task {
                    await authManager.checkBiometricAvailability()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .fullScreenCover(isPresented: $showingAuthenticationView) {
                AuthenticationView(authManager: authManager)
                    .onDisappear {
                        // Always refresh biometric status after authentication attempt
                        Task {
                            await authManager.checkBiometricAvailability()
                        }

                        // If authentication failed and the user dismissed the view,
                        // revert the authentication toggle
                        if !authManager.isAuthenticated {
                            authManager.isAuthenticationEnabled = false
                        }
                    }
            }
        }
    }
}

#Preview {
    @MainActor
    struct PreviewWrapper: View {
        @StateObject private var settingsManager = SettingsManager()
        @StateObject private var authManager = AuthenticationManager()

        var body: some View {
            SettingsView(settingsManager: settingsManager, authManager: authManager)
        }
    }

    return PreviewWrapper()
}
