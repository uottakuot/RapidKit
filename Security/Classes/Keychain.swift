// MIT License
//
// Copyright (c) Uottakuot Software
// https://github.com/uottakuot/RapidKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import RapidFoundation

public class Keychain {
    public static let shared = Keychain()
    
    public var defaultService: String?
    
    private init() {
        //
    }
    
    public func data(forKey key: String, account: String? = nil, service: String? = nil, accessGroup: String? = nil, synchronizable: Bool? = nil) -> Data? {
        guard var attributes = attributes(forKey: key, account: account, service: service, accessGroup: accessGroup, synchronizable: synchronizable) else {
            return nil
        }
        
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne
        attributes[kSecReturnData as String] = kCFBooleanTrue
        
        var result: AnyObject?
        SecItemCopyMatching(attributes as CFDictionary, &result)
        
        return result as? Data
    }
    
    public func string(forKey key: String, account: String? = nil, service: String? = nil, accessGroup: String? = nil, synchronizable: Bool? = nil) -> String? {
        guard let data = data(forKey: key, account: account, service: service, accessGroup: accessGroup, synchronizable: synchronizable) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    @discardableResult
    public func set(_ data: Data?, forKey key: String, account: String? = nil, service: String? = nil, accessGroup: String? = nil, synchronizable: Bool? = nil) -> Bool {
        guard let attributes = attributes(forKey: key, account: account, service: service, accessGroup: accessGroup, synchronizable: synchronizable) else {
            return false
        }
        
        if let data = data {
            var status = SecItemUpdate(attributes as CFDictionary, [kSecValueData as String: data] as CFDictionary)
            
            if status == errSecItemNotFound {
                var attributes = attributes
                attributes[kSecValueData as String] = data
                
                status = SecItemAdd(attributes as CFDictionary, nil)
            }
            
            return status == errSecSuccess
        } else {
            return SecItemDelete(attributes as CFDictionary) == errSecSuccess
        }
    }
    
    @discardableResult
    public func set(_ string: String?, forKey key: String, account: String? = nil, service: String? = nil, accessGroup: String? = nil, synchronizable: Bool? = nil) -> Bool {
        let data = string?.data(using: .utf8)
        
        guard data != nil || string.isEmptyOrNil else {
            return false
        }
        
        return set(data, forKey: key, account: account, service: service, accessGroup: accessGroup, synchronizable: synchronizable)
    }
    
    private func attributes(forKey key: String, account: String? = nil, service: String? = nil, accessGroup: String? = nil, synchronizable: Bool? = nil) -> [String: Any]? {
        guard let encodedKey = key.data(using: .utf8) else {
            return nil
        }
        
        var attributes: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrGeneric: encodedKey
        ]
        
        if let account = account {
            attributes[kSecAttrAccount] = account
        } else {
            attributes[kSecAttrAccount] = encodedKey
        }
        
        if let service = service {
            attributes[kSecAttrService] = service
        } else {
            attributes[kSecAttrService] = defaultService
        }
        
        if let accessGroup = accessGroup {
            attributes[kSecAttrAccessGroup] = accessGroup
        }
        
        if let synchronizable = synchronizable {
            attributes[kSecAttrSynchronizable] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse
        }
        
        return attributes as [String: Any]
    }
}
