import SwiftUI

import CocktailsKit

struct CocktailDetailView: View {
    let cocktail: Cocktail
    let dataManager: CocktailDataManager

    @State private var isFavorite: Bool

    init(cocktail: Cocktail, dataManager: CocktailDataManager) {
        self.cocktail = cocktail
        self.dataManager = dataManager
        self._isFavorite = State(initialValue: dataManager.isFavorite(cocktailID: cocktail.id))
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
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                    )

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

                    ForEach(cocktail.ingredients.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(cocktail.ingredients[index])
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
                Button(
                    action: {
                        dataManager.toggleFavorite(cocktailID: cocktail.id)
                        isFavorite = dataManager.isFavorite(cocktailID: cocktail.id)
                    },
                    label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .gray)
                            .font(.title2)
                    }
                )
            }
        }
        .onAppear {
            isFavorite = dataManager.isFavorite(cocktailID: cocktail.id)
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
            longDescription: "The Margarita is a cocktail consisting of tequila, orange liqueur, " +
                "and lime juice often served with salt on the rim.",
            preparationMinutes: 5,
            imageName: "margarita_image",
            ingredients: ["Tequila", "Triple sec", "Lime juice", "Salt"]
        ),
        dataManager: CocktailDataManager(cocktailsAPI: FakeCocktailsAPI())
    )
}
