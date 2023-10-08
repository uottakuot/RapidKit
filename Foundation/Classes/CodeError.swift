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
/// Every code can have an associated description in localization strings with "Error [code]" key
/// which results in the final error description.
public struct CodeError: Error, Equatable {
    public static func ==(lhs: CodeError, rhs: CodeError) -> Bool {
        return lhs.codes == rhs.codes
    }
    
    public let codes: [Int]
    
    public let description: String
    
    public init(_ codes: [Int], description: String? = nil) {
        self.codes = codes
        
        self.description = (description.isEmptyOrNil ? localizedString("Error") : description!) + ": " + {
            let descriptions = codes.map { code -> String in
                let descriptionKey = "Error \(code)"
                let description = localizedString(descriptionKey)
                if description != descriptionKey {
                    return "[\(code)] \(description)"
                }
                
                return String(code)
            }
            
            return descriptions.joined(separator: ", ")
        }()
    }
    
    public init(_ code: Int, description: String? = nil) {
        self.init([code], description: description)
    }
    
    public func containsCode(_ code: Int) -> Bool {
        return self.codes.contains(code)
    }
}

extension CodeError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}

extension CodeError {
    public static let unknown = Self(0, description: "Unknown error")
    
    public static let notImplemented = Self(-1, description: "Not implemented")
}
