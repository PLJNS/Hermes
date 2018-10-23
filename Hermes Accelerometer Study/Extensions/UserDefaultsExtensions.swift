//
//  UserDefaultsExtensions.swift
//  Hermes Accelerometer Study
//
//  Created by Paul Jones on 10/16/18.
//  Copyright © 2018 Paul Jones. All rights reserved.
//

import Foundation

/// Your object can be converted into a user defaults key. See UserDefaultsExtensions.
protocol UserDefaultsKeyConvertible {
    
    /// The key.
    var userDefaultsKey: String { get }
    
}

enum UserDefaultsKeys: String, UserDefaultsKeyConvertible {
    case updateInterval = "updateInterval"
    
    var userDefaultsKey: String {
        return rawValue
    }
    
}

extension UserDefaults {
    
    var updateInterval: Float {
        get {
            return float(forKey: UserDefaultsKeys.updateInterval)
        } set {
            set(newValue, forKey: UserDefaultsKeys.updateInterval)
        }
    }

}

// MARK: - Pass a user defaults convertible instead of a string to get a user default.
extension UserDefaults {
    
    func removeAllObjects() {
        for key in dictionaryRepresentation().keys {
            removeObject(forKey: key)
        }
    }
    
    func removeObjects(_ objects: [UserDefaultsKeyConvertible]) {
        for keyConvertible in objects {
            removeObject(forKey: keyConvertible.userDefaultsKey)
        }
    }
    
    func decode<T: Codable>(forKey defaultName: UserDefaultsKeyConvertible) -> T? {
        if let data = object(forKey: defaultName.userDefaultsKey) as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        } else {
            return nil
        }
    }
    
    func encode<T: Codable>(_ value: T?, forKey defaultName: UserDefaultsKeyConvertible) {
        if let encodedValue = try? JSONEncoder().encode(value) {
            set(encodedValue, forKey: defaultName.userDefaultsKey)
        }
    }
    
    func object<T>(forKey defaultName: UserDefaultsKeyConvertible) -> T? {
        return object(forKey: defaultName.userDefaultsKey) as? T
    }
    
    func object(forKey defaultName: UserDefaultsKeyConvertible) -> Any? {
        return object(forKey: defaultName.userDefaultsKey)
    }
    
    func set(_ value: Any?, forKey defaultName: UserDefaultsKeyConvertible) {
        set(value, forKey: defaultName.userDefaultsKey)
    }
    
    func removeObject(forKey defaultName: UserDefaultsKeyConvertible) {
        removeObject(forKey: defaultName.userDefaultsKey)
    }
    
    func string(forKey defaultName: UserDefaultsKeyConvertible) -> String? {
        return string(forKey: defaultName.userDefaultsKey)
    }
    
    func array(forKey defaultName: UserDefaultsKeyConvertible) -> [Any]? {
        return array(forKey: defaultName.userDefaultsKey)
    }
    
    func dictionary(forKey defaultName: UserDefaultsKeyConvertible) -> [String: Any]? {
        return dictionary(forKey: defaultName.userDefaultsKey)
    }
    
    func data(forKey defaultName: UserDefaultsKeyConvertible) -> Data? {
        return data(forKey: defaultName.userDefaultsKey)
    }
    
    func stringArray(forKey defaultName: UserDefaultsKeyConvertible) -> [String]? {
        return stringArray(forKey: defaultName.userDefaultsKey)
    }
    
    func integer(forKey defaultName: UserDefaultsKeyConvertible) -> Int {
        return integer(forKey: defaultName.userDefaultsKey)
    }
    
    func float(forKey defaultName: UserDefaultsKeyConvertible) -> Float {
        return float(forKey: defaultName.userDefaultsKey)
    }
    
    func double(forKey defaultName: UserDefaultsKeyConvertible) -> Double {
        return double(forKey: defaultName.userDefaultsKey)
    }
    
    func bool(forKey defaultName: UserDefaultsKeyConvertible) -> Bool {
        return bool(forKey: defaultName.userDefaultsKey)
    }
    
    func url(forKey defaultName: UserDefaultsKeyConvertible) -> URL? {
        return url(forKey: defaultName.userDefaultsKey)
    }
    
    func set(_ value: Int, forKey defaultName: UserDefaultsKeyConvertible) {
        set(value, forKey: defaultName.userDefaultsKey)
    }
    
    func set(_ value: Float, forKey defaultName: UserDefaultsKeyConvertible) {
        set(value, forKey: defaultName.userDefaultsKey)
    }
    
    func set(_ value: Double, forKey defaultName: UserDefaultsKeyConvertible) {
        set(value, forKey: defaultName.userDefaultsKey)
    }
    
    func set(_ value: Bool, forKey defaultName: UserDefaultsKeyConvertible) {
        set(value, forKey: defaultName.userDefaultsKey)
    }
    
    func set(_ url: URL?, forKey defaultName: UserDefaultsKeyConvertible) {
        set(url, forKey: defaultName.userDefaultsKey)
    }
    
}
