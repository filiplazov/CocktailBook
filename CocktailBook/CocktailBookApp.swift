import CocktailsKit
import SwiftUI

@main
struct CocktailBookApp: App {
    @StateObject private var dataManager = CocktailDataManager(cocktailsAPI: FakeCocktailsAPI())
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            CocktailListView(
                dataManager: dataManager,
                settingsManager: settingsManager,
                authManager: authManager
            )
        }
    }
}
