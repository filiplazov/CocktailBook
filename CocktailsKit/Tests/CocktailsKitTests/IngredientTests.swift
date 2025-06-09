import XCTest
@testable import CocktailsKit

final class IngredientTests: XCTestCase {
    
    func testIngredient_Initialization_SetsAllProperties() {
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")
        
        XCTAssertEqual(ingredient.imperialAmount, "2 oz")
        XCTAssertEqual(ingredient.name, "Tequila")
        XCTAssertEqual(ingredient.metricAmount, "60 ml")
    }
    
    func testIngredient_DisplayString_ReturnsFormattedString() {
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")
        XCTAssertEqual(ingredient.displayString, "2 oz Tequila")
        
        let emptyAmountIngredient = Ingredient(imperialAmount: "", name: "Salt", metricAmount: "")
        XCTAssertEqual(emptyAmountIngredient.displayString, "Salt")
    }
    
    func testIngredient_MetricDisplayString_ReturnsFormattedMetricString() {
        let ingredient = Ingredient(imperialAmount: "2 oz", name: "Tequila", metricAmount: "60 ml")
        XCTAssertEqual(ingredient.metricDisplayString, "60 ml Tequila")
        
        let emptyMetricIngredient = Ingredient(imperialAmount: "1 cup", name: "Salt", metricAmount: "")
        XCTAssertEqual(emptyMetricIngredient.metricDisplayString, "Salt")
    }
    
    func testIngredient_JSONSerialization_EncodesAndDecodesCorrectly() throws {
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
    
    func testIngredient_JSONDeserialization_WithImperialAmountKey_DecodesCorrectly() throws {
        // Test that we can deserialize JSON that uses "imperialAmount" key
        let jsonString = """
        {
            "imperialAmount": "2 oz",
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