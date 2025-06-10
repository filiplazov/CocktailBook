import CocktailsKit
import SwiftUI

@main
struct CocktailBookApp: App {
    @StateObject private var viewModel = CocktailListViewModel(cocktailsAPI: FakeCocktailsAPI())
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            CocktailListView(
                viewModel: viewModel,
                settingsManager: settingsManager,
                authManager: authManager
            )
        }
    }
}
