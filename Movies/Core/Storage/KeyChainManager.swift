//
//  KeyChainManager.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation
import Security

/// `KeychainManagerKeys` is an enum that defines keys used to save, retrieve, and delete data in the keychain.
enum KeychainManagerKeys: String {
    
    // Authentication-related keys
    case token = "token"  // For storing the authentication token
}

/// `KeychainManager` is a class responsible for securely storing, retrieving, and deleting data in the keychain.
final class KeychainManager {
    
    /// Saves a string value to the keychain associated with a specified key.
    ///
    /// - Parameters:
    ///   - key: The key against which the value will be stored.
    ///   - value: The string value to be stored.
    /// - Returns: Boolean indicating whether the save operation was successful or not.
    static func save(key: KeychainManagerKeys, value: String) -> Bool {
        // Convert the string value to data
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        // Create a query to identify the item in the keychain
        let query = [
                kSecClass as String       : kSecClassGenericPassword as String,
                kSecAttrAccount as String : key.rawValue,
                kSecValueData as String   : data] as [String : Any]

        // Remove any existing item with the same key
        SecItemDelete(query as CFDictionary)

        // Add the new item to the keychain
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        
        // Check if the save was successful
        return (addStatus == errSecSuccess)
    }
    
    /// Deletes a value from the keychain associated with a specified key.
    ///
    /// - Parameter key: The key against which the value will be deleted.
    static func delete(key: KeychainManagerKeys) {
        // Create a query to identify the item in the keychain
        let query = [
                kSecClass as String       : kSecClassGenericPassword as String,
                kSecAttrAccount as String : key.rawValue]

        // Delete the item from the keychain
        SecItemDelete(query as CFDictionary)
    }
    
    /// Retrieves a string value from the keychain associated with a specified key.
    ///
    /// - Parameter key: The key against which the value will be retrieved.
    /// - Returns: The retrieved string value, or `nil` if retrieval fails.
    static func load(key: KeychainManagerKeys) -> String? {
        // Create a query to identify and retrieve the item from the keychain
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key.rawValue,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        // Placeholder for the retrieved data
        var dataTypeRef: AnyObject? = nil

        // Perform the query
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        // Check if retrieval was successful
        if status == noErr {
            if let dtr = dataTypeRef, let data = dtr as? Data {
                // Convert retrieved data to string
                let val = String(decoding: data, as: UTF8.self)
                
                // Log for debugging purposes
                print("KeychainManager loaded data for key: \(key.rawValue) and value is: \(val)")
                
                return val
            } else {
                // Log for debugging purposes
                print("KeychainManager load data failed because value is nil for key: \(key.rawValue)")
                
                return nil
            }
        } else {
            // Log for debugging purposes
            print("KeychainManager load data failed because of status error for key: \(key.rawValue)")
            
            return nil
        }
    }
}
