import SwiftUI
import CocktailsKit

@main
struct CocktailBookApp: App {
    @StateObject private var dataManager = CocktailDataManager(cocktailsAPI: FakeCocktailsAPI())
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            CocktailListView(dataManager: dataManager, settingsManager: settingsManager)
        }
    }
}
