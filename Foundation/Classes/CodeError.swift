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

/// Error with several error codes.
///
/// # Example #:
/// ```
/// extension CodeError.Code {
///     static let myError1 = Self(1001)
///     static let myError2 = Self(1002)
/// }
///
/// let error = CodeError(codes: [.myError1, .myError2])
/// ```
public struct CodeError: Error {
    public struct Code: Equatable {
        public static let none = Self(0)
        
        public static func ==(lhs: Code, rhs: Code) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public let rawValue: Int
        
        public init(_ rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public let codes: [Code]
    
    public let description: String
    
    public init(codes: [Code], description: String? = nil) {
        self.codes = codes
        
        self.description = description ?? {
            for code in codes {
                let descriptionKey = "Error_\(code.rawValue)"
                let description = localizedString(descriptionKey)
                
                if description != descriptionKey {
                    return "[\(code.rawValue)] \(description)"
                }
            }
            
            let numbers = codes.map { String($0.rawValue) }
            return "Error \(numbers.joined(separator: ", "))"
        }()
    }
    
    public init(code: Code, description: String? = nil) {
        self.init(codes: [code], description: description)
    }
    
    public func containsCode(_ code: Code) -> Bool {
        return self.codes.contains(code)
    }
    
    public func containsCode(_ code: Int) -> Bool {
        return self.codes.contains { $0.rawValue == code }
    }
}

extension CodeError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}
