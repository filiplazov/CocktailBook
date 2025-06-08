import SwiftUI
import CocktailsKit

@main
struct CocktailBookApp: App {
    @StateObject private var dataManager = CocktailDataManager(cocktailsAPI: FakeCocktailsAPI())
    
    var body: some Scene {
        WindowGroup {
            CocktailListView(dataManager: dataManager)
        }
    }
}
