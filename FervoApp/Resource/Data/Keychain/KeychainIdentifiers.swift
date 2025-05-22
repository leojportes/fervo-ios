//
//  KeychainIdentifiers.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 21/05/25.
//

import Foundation

struct KeychainIdentifiers {
    static let emailKey = "fervo_email"
    static let accessGroup = "security_service"
    static let passwordKey = "fervo_password"
}

let describe: String = "Nothing was retrieved from the keychain. Status code"
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class KeychainService: NSObject {

    public class func saveCredentials(email: String ,password: String) {
        if let pass = password as NSString? {
            if let usr = email as NSString? {
                self.save(service: KeychainIdentifiers.passwordKey as NSString, data: pass)
                self.save(service: KeychainIdentifiers.emailKey as NSString, data: usr)
            }
        }
    }

    public class func loadCredentials() -> [String] {
        if let pass = self.load(service: KeychainIdentifiers.passwordKey as NSString) {
            if let usr = self.load(service: KeychainIdentifiers.emailKey as NSString) {
                return ["\(usr)","\(pass)"]
            }
        }
        return [.empty]
    }

    public class func deleteCredentials() {
        self.delete()
    }

    public class func verifyIfExists() -> Bool {
        return self.verifyIfExists(service: KeychainIdentifiers.emailKey as NSString)
    }

    private class func save(service: NSString, data: NSString) {
        guard let dataFromString: NSData = data.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) as NSData? else { return }

        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, KeychainIdentifiers.emailKey, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])

        SecItemDelete(keychainQuery as CFDictionary)

        SecItemAdd(keychainQuery as CFDictionary, nil)
    }

    private class func load(service: NSString) -> NSString? {
        guard let kBooleanTrue = kCFBooleanTrue else { return nil }
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, KeychainIdentifiers.emailKey, kBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])

        var contentsOfKeychain: NSString? = nil

        if verifyIfExists(service: service) {
            var dataTypeRef: AnyObject?
            SecItemCopyMatching(keychainQuery, &dataTypeRef)
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        }
        return contentsOfKeychain
    }

    private class func delete() {
        let secItemClasses = [kSecClassGenericPasswordValue]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }

    private class func verifyIfExists(service: NSString) -> Bool {
        guard let kBooleanTrue = kCFBooleanTrue else { return false }
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, KeychainIdentifiers.emailKey, kBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        if status == errSecSuccess {
            return true
        }
        return false
    }
}
