import SwiftUI
import Combine

struct CocktailListView: View {
    @StateObject private var dataManager: CocktailDataManager
    
    init(dataManager: CocktailDataManager = CocktailDataManager(cocktailsAPI: FakeCocktailsAPI())) {
        self._dataManager = StateObject(wrappedValue: dataManager)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Controls
                Picker("Filter", selection: $dataManager.filterType) {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                if dataManager.isLoading {
                    Spacer()
                    ProgressView("Loading cocktails...")
                        .font(.headline)
                    Spacer()
                } else if let errorMessage = dataManager.errorMessage {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 64))
                            .foregroundColor(.orange)
                        
                        Text("Failed to load cocktails")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            dataManager.loadData()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else {
                    List(dataManager.filteredCocktails) { cocktail in
                        NavigationLink(destination: CocktailDetailView(
                            cocktail: cocktail,
                            dataManager: dataManager
                        )) {
                            CocktailRowView(
                                cocktail: cocktail,
                                onToggleFavorite: { cocktailID in
                                    dataManager.toggleFavorite(cocktailID: cocktailID)
                                }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if dataManager.allCocktails.isEmpty && !dataManager.isLoading && dataManager.errorMessage == nil {
                dataManager.loadData()
            }
        }
    }
    
    private var navigationTitle: String {
        switch dataManager.filterType {
        case .all:
            return "All Cocktails"
        case .alcoholic:
            return "Alcoholic Cocktails"
        case .nonAlcoholic:
            return "Non-Alcoholic Cocktails"
        }
    }
}

struct CocktailRowView: View {
    let cocktail: Cocktail
    let onToggleFavorite: (String) -> Void
    
    var body: some View {
        HStack {
            // Cocktail Image (using bundle images)
            Image(cocktail.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                )
            
            // Cocktail Info
            VStack(alignment: .leading, spacing: 4) {
                Text(cocktail.name)
                    .font(.headline)
                    .foregroundColor(cocktail.isFavorite ? .red : .primary)
                
                Text(cocktail.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Favorite Button (only show if favorite)
            if cocktail.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // Make entire row tappable
    }
}



#Preview {
    CocktailListView()
} 