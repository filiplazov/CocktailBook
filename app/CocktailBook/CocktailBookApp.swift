import CocktailsKit
import SwiftUI

@main
struct CocktailBookApp: App {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var cocktailListViewModel: CocktailListViewModel = {
        let api: CocktailsAPI = SettingsManager().useFakeAPI ? FakeCocktailsAPI() : NetworkCocktailsAPI()
        return CocktailListViewModel(cocktailsAPI: api)
    }()
    
    var body: some Scene {
        WindowGroup {
            CocktailListView(
                viewModel: cocktailListViewModel,
                settingsManager: settingsManager,
                authManager: authManager
            )
        }
    }
}

