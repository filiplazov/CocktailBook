import XCTest
@testable import CocktailsKit

final class IngredientTests: XCTestCase {
    
    func testIngredientInitialization() {
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")
        
        XCTAssertEqual(ingredient.imperialAmount, "2 oz")
        XCTAssertEqual(ingredient.name, "Tequila")
        XCTAssertEqual(ingredient.metricAmount, "60 ml")
    }
    
    func testDisplayString() {
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")
        XCTAssertEqual(ingredient.displayString, "2 oz Tequila")
        
        let emptyAmountIngredient = Ingredient(imperialAmount: "", name: "Salt", metricAmount: "")
        XCTAssertEqual(emptyAmountIngredient.displayString, "Salt")
    }
    
    func testMetricDisplayString() {
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")
        XCTAssertEqual(ingredient.metricDisplayString, "60 ml Tequila")
        
        let emptyMetricIngredient = Ingredient(imperialAmount: "1 cup", name: "Salt", metricAmount: "")
        XCTAssertEqual(emptyMetricIngredient.metricDisplayString, "Salt")
    }
    
    func testJSONSerialization() throws {
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")
        
        // Encode to JSON
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(ingredient)
        
        // Decode from JSON
        let decoder = JSONDecoder()
        let decodedIngredient = try decoder.decode(Ingredient.self, from: jsonData)
        
        XCTAssertEqual(decodedIngredient.imperialAmount, ingredient.imperialAmount)
        XCTAssertEqual(decodedIngredient.name, ingredient.name)
        XCTAssertEqual(decodedIngredient.metricAmount, ingredient.metricAmount)
    }
    
    func testJSONDeserializationFromLegacyFormat() throws {
        // Test that we can still deserialize JSON that uses "amount" key
        let jsonString = """
        {
            "amount": "2 oz",
            "name": "Tequila",
            "metricAmount": "60 ml"
        }
        """
        
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        let ingredient = try decoder.decode(Ingredient.self, from: jsonData)
        
        XCTAssertEqual(ingredient.imperialAmount, "2 oz")
        XCTAssertEqual(ingredient.name, "Tequila")
        XCTAssertEqual(ingredient.metricAmount, "60 ml")
    }
} 