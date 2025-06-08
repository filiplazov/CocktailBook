import Foundation

protocol UserDefaultsProtocol {
    func array(forKey defaultName: String) -> [Any]?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {}
