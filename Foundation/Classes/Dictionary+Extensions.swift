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

public typealias JSONDictionary = [String: Any]

extension Dictionary where Value: Any {
    public func string(forKey key: Key) -> String? {
        guard let value = self[key] else {
            return nil
        }
        
        if let result = value as? String {
            return result
        }
        
        return "\(value)"
    }
    
    public func boolean(forKey key: Key) -> Bool? {
        return self[key] as? Bool
    }
    
    public func integer(forKey key: Key) -> Int? {
        if let result = self[key] as? Int {
            return result
        }
        
        if let string = string(forKey: key) {
            return Int(string)
        }
        
        return nil
    }
    
    public func uinteger(forKey key: Key) -> UInt? {
        if let result = self[key] as? UInt {
            return result
        }
        
        if let string = string(forKey: key) {
            return UInt(string)
        }
        
        return nil
    }
    
    public func float(forKey key: Key) -> Float? {
        if let result = self[key] as? Float {
            return result
        }
        
        if let string = string(forKey: key) {
            return Float(string)
        }
        
        return nil
    }
    
    public func double(forKey key: Key) -> Double? {
        if let result = self[key] as? Double {
            return result
        }
        
        if let string = string(forKey: key) {
            return Double(string)
        }
        
        return nil
    }
    
    public func jsonArray(forKey key: Key) -> JSONArray? {
        return self[key] as? JSONArray
    }
    
    public func jsonDictionary(forKey key: Key) -> JSONDictionary? {
        return self[key] as? JSONDictionary
    }
}
