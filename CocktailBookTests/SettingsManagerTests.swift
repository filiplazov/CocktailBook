@testable import CocktailBook
import XCTest

@MainActor
final class SettingsManagerTests: XCTestCase {
    var settingsManager: SettingsManager!
    var mockUserDefaults: MockUserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        settingsManager = SettingsManager(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        settingsManager = nil
        mockUserDefaults = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_WithNoSavedData_DefaultsToImperialSystem() {
        // Given
        mockUserDefaults.removeObject(forKey: "measurementSystem")

        // When
        let manager = SettingsManager(userDefaults: mockUserDefaults)

        // Then
        XCTAssertEqual(manager.measurementSystem, .imperial)
        XCTAssertEqual(mockUserDefaults.object(forKey: "measurementSystem") as? String, "imperial")
    }

    func testInit_WithSavedMetricSystem_LoadsSavedValue() {
        // Given
        mockUserDefaults.set("metric", forKey: "measurementSystem")

        // When
        let manager = SettingsManager(userDefaults: mockUserDefaults)

        // Then
        XCTAssertEqual(manager.measurementSystem, .metric)
    }

    func testInit_WithInvalidSavedData_DefaultsToImperialSystem() {
        // Given
        mockUserDefaults.set("invalid", forKey: "measurementSystem")

        // When
        let manager = SettingsManager(userDefaults: mockUserDefaults)

        // Then
        XCTAssertEqual(manager.measurementSystem, .imperial)
        XCTAssertEqual(mockUserDefaults.object(forKey: "measurementSystem") as? String, "imperial")
    }

    // MARK: - Measurement System Update Tests

    func testMeasurementSystemUpdate_ToMetric_SavesAndUpdatesValue() {
        // Given
        XCTAssertEqual(settingsManager.measurementSystem, .imperial)

        // When
        settingsManager.measurementSystem = .metric

        // Then
        XCTAssertEqual(settingsManager.measurementSystem, .metric)
        XCTAssertEqual(mockUserDefaults.object(forKey: "measurementSystem") as? String, "metric")
    }

    func testMeasurementSystemUpdate_ToImperial_SavesAndUpdatesValue() {
        // Given
        settingsManager.measurementSystem = .metric

        // When
        settingsManager.measurementSystem = .imperial

        // Then
        XCTAssertEqual(settingsManager.measurementSystem, .imperial)
        XCTAssertEqual(mockUserDefaults.object(forKey: "measurementSystem") as? String, "imperial")
    }

    func testMeasurementSystemUpdate_MultipleChanges_SavesEachValue() {
        // Given
        let systems: [MeasurementSystem] = [.metric, .imperial, .metric, .imperial, .metric]

        // When & Then
        for system in systems {
            settingsManager.measurementSystem = system
            XCTAssertEqual(settingsManager.measurementSystem, system)
            XCTAssertEqual(mockUserDefaults.object(forKey: "measurementSystem") as? String, system.rawValue)
        }
    }

    // MARK: - Publisher Tests

    func testMeasurementSystemPublisher_OnValueChange_EmitsNewValues() {
        // Given
        var publishedValues: [MeasurementSystem] = []
        let expectation = XCTestExpectation(description: "Publisher should emit values")

        let cancellable = settingsManager.$measurementSystem
            .sink { value in
                publishedValues.append(value)
                if publishedValues.count == 3 {
                    expectation.fulfill()
                }
            }

        // When
        settingsManager.measurementSystem = .metric
        settingsManager.measurementSystem = .imperial

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(publishedValues, [.imperial, .metric, .imperial])

        cancellable.cancel()
    }

    // MARK: - Persistence Tests

    func testPersistence_AcrossInstances_MaintainsSavedValue() {
        // Given
        settingsManager.measurementSystem = .metric

        // When
        let newManager = SettingsManager(userDefaults: mockUserDefaults)

        // Then
        XCTAssertEqual(newManager.measurementSystem, .metric)
    }
}

// MARK: - MeasurementSystem Tests

final class MeasurementSystemTests: XCTestCase {
    func testMeasurementSystemRawValues_AllCases_MatchExpectedStrings() {
        XCTAssertEqual(MeasurementSystem.imperial.rawValue, "imperial")
        XCTAssertEqual(MeasurementSystem.metric.rawValue, "metric")
    }

    func testMeasurementSystemDisplayNames_AllCases_MatchExpectedNames() {
        XCTAssertEqual(MeasurementSystem.imperial.displayName, "Imperial")
        XCTAssertEqual(MeasurementSystem.metric.displayName, "Metric")
    }

    func testMeasurementSystemCaseIterable_AllCases_ContainsBothValues() {
        let allCases = MeasurementSystem.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.imperial))
        XCTAssertTrue(allCases.contains(.metric))
    }

    func testMeasurementSystemInit_FromRawValue_ReturnsCorrectCase() {
        XCTAssertEqual(MeasurementSystem(rawValue: "imperial"), .imperial)
        XCTAssertEqual(MeasurementSystem(rawValue: "metric"), .metric)
        XCTAssertNil(MeasurementSystem(rawValue: "invalid"))
    }
}
