import Foundation
@testable import CocktailBook

class MockUserDefaults: UserDefaultsProtocol {
    private var storage: [String: Any] = [:]
    
    func array(forKey defaultName: String) -> [Any]? {
        return storage[defaultName] as? [Any]
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
} 