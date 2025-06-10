import CocktailsKit
import SwiftUI

struct CocktailDetailView: View {
    let cocktail: Cocktail
    let viewModel: CocktailListViewModel
    let settingsManager: SettingsManager

    @State private var isFavorite: Bool

    init(cocktail: Cocktail, viewModel: CocktailListViewModel, settingsManager: SettingsManager) {
        self.cocktail = cocktail
        self.viewModel = viewModel
        self.settingsManager = settingsManager
        self._isFavorite = State(initialValue: cocktail.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Cocktail Image
                Image(cocktail.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Preparation Time
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("\(cocktail.preparationMinutes) minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }

                // Long Description
                Text(cocktail.longDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                // Ingredients
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)
                        .foregroundColor(.primary)

                    ForEach(cocktail.ingredients, id: \.id) { ingredient in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(viewModel.ingredientDisplayString(
                                for: ingredient,
                                measurementSystem: settingsManager.measurementSystem
                            ))
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.bottom, 20) // Extra bottom padding for better scrolling
        }
        .navigationTitle(cocktail.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleFavorite(cocktailID: cocktail.id)
                    isFavorite = viewModel.isFavorite(cocktailID: cocktail.id)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .font(.title2)
                }
            }
        }
        .onAppear {
            isFavorite = viewModel.isFavorite(cocktailID: cocktail.id)
        }
    }
}

#Preview {
    CocktailDetailView(
        cocktail: Cocktail(
            id: "preview-1",
            name: "Preview Margarita",
            type: .alcoholic,
            shortDescription: "A classic tequila cocktail",
            longDescription: "The Margarita is a cocktail consisting of tequila, orange liqueur, and " +
                           "lime juice often served with salt on the rim of the glass.",
            preparationMinutes: 5,
            imageName: "margarita_image",
            ingredients: [
                Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "1 oz", name: "Triple sec", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "1 oz", name: "Lime juice", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "", name: "Salt", metricAmount: "")
            ]
        ),
        viewModel: CocktailListViewModel(cocktailsAPI: FakeCocktailsAPI()),
        settingsManager: SettingsManager()
    )
}
