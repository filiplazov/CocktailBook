@testable import CocktailBook
import XCTest

final class FilterTypeTests: XCTestCase {
    // MARK: - FilterType Tests

    func testFilterType_AllCases_ReturnsCorrectTitles() {
        XCTAssertEqual(FilterType.all.title, "All Cocktails")
        XCTAssertEqual(FilterType.alcoholic.title, "Alcoholic Cocktails")
        XCTAssertEqual(FilterType.nonAlcoholic.title, "Non-Alcoholic Cocktails")
    }

    func testFilterType_AllCases_ContainsExpectedValues() {
        let allCases = FilterType.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.alcoholic))
        XCTAssertTrue(allCases.contains(.nonAlcoholic))
    }
}
