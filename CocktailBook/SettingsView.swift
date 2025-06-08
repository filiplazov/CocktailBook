import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
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
                } footer: {
                    Text("Choose between Imperial (oz, fl oz) and Metric (ml, cl) measurements for cocktail ingredients.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    @MainActor
    struct PreviewWrapper: View {
        @StateObject private var settingsManager = SettingsManager()
        
        var body: some View {
            SettingsView(settingsManager: settingsManager)
        }
    }
    
    return PreviewWrapper()
} 