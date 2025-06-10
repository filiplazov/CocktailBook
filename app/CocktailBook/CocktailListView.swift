import CocktailsKit
import SwiftUI

struct CocktailListView: View {
    @ObservedObject var viewModel: CocktailListViewModel
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var authManager: AuthenticationManager
    @State private var showingSettings = false
    @State private var showingAuthentication = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Controls
                Picker("Filter", selection: $viewModel.filterType) {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading cocktails...")
                        .font(.headline)
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
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
                            Task {
                                await viewModel.loadData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else {
                    List(viewModel.filteredCocktails) { cocktail in
                        NavigationLink(destination: CocktailDetailView(
                            cocktail: cocktail,
                            viewModel: viewModel,
                            settingsManager: settingsManager
                        )) {
                            CocktailRowView(
                                cocktail: cocktail
                            ) { cocktailID in
                                viewModel.toggleFavorite(cocktailID: cocktailID)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settingsManager: settingsManager, authManager: authManager)
            }
            .fullScreenCover(isPresented: $showingAuthentication) {
                AuthenticationView(authManager: authManager)
            }
        }
        .task {
            // Reset authentication for new session
            authManager.resetAuthenticationForNewSession()

            // Show authentication if required
            if authManager.isAuthenticationEnabled && !authManager.isAuthenticated {
                showingAuthentication = true
            } else {
                // Load data if authentication is disabled or already authenticated
                if viewModel.allCocktails.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    await viewModel.loadData()
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            // Load data after successful authentication
            if isAuthenticated && viewModel.allCocktails.isEmpty &&
               !viewModel.isLoading && viewModel.errorMessage == nil {
                Task {
                    await viewModel.loadData()
                }
            }
        }
    }

    private var navigationTitle: String {
        switch viewModel.filterType {
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
    @MainActor
    struct PreviewWrapper: View {
        @StateObject private var viewModel = CocktailListViewModel(cocktailsAPI: FakeCocktailsAPI())
        @StateObject private var settingsManager = SettingsManager()
        @StateObject private var authManager = AuthenticationManager()

        var body: some View {
            CocktailListView(viewModel: viewModel, settingsManager: settingsManager, authManager: authManager)
        }
    }

    return PreviewWrapper()
}
