//
//  FVUserDefault.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 21/05/25.
//

import Foundation

public class FVUserDefault {
    private static let defaults = UserDefaults.standard

    // MARK: - Set Codable
    public static func setObject<T: Codable>(_ value: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
            defaults.synchronize()
        } catch {
            print("Erro ao salvar objeto Codable: \(error)")
        }
    }

    // MARK: - Get Codable
    public static func getObject<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            print("Erro ao recuperar objeto Codable: \(error)")
            return nil
        }
    }

    // MARK: Check
    public static func checkExistenceKey(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }

    // MARK: Set
    public static func set(value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    public static func set(value: String, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    public static func set(value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }

    // MARK: - Get
    public static func get(intForKey: String) -> Int? {
        if checkExistenceKey(key: intForKey) == false {
            return nil
        }
        return defaults.integer(forKey: intForKey)
    }

    public static func get(boolForKey: String) -> Bool? {
        if checkExistenceKey(key: boolForKey) == false {
            return nil
        }
        return defaults.bool(forKey: boolForKey)
    }

    public static func get(stringForKey: String) -> String? {
        if checkExistenceKey(key: stringForKey) == false {
            return nil
        }
        return defaults.string(forKey: stringForKey)
    }

    // MARK: - Remove
    public static func remove(key: String) {
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
}

public enum FVKeys {
    public static let authenticated = "key_authenticated"
    public static let email = "key_email"
    public static let currentUser = "key_current_user"
}
