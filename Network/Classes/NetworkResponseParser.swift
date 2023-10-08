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

public protocol NetworkResponseParser {
    func parse(_ data: Data) throws
}

extension Network {
    /// Base parser class.
    open class DataResponseParser: NetworkResponseParser {
        public private(set) var data: Data?
        
        public init() {
            //
        }
        
        open func parse(_ data: Data) throws {
            guard data.count > 0 else {
                return
            }
            
            self.data = data
        }
    }
    
    open class StringResponseParser: DataResponseParser {
        public private(set) var string: String?
        
        public override init() {
            super.init()
        }
        
        open override func parse(_ data: Data) throws {
            guard let string = String(data: data, encoding: .utf8) else {
                throw CodeError.cantParseNetworkResponse
            }
            
            self.string = string
            
            try parse(string)
        }
        
        open func parse(_ data: String) throws {
            //
        }
    }
    
    open class JSONResponseParser: DataResponseParser {
        public private(set) var json: Any?
        
        public override init() {
            super.init()
        }
        
        open override func parse(_ data: Data) throws {
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) else {
                throw CodeError.cantParseNetworkResponse
            }
            
            self.json = json
            
            try parse(json)
        }
        
        open func parse(_ data: Any) throws {
            //
        }
    }
    
    open class JSONDictionaryResponseParser: JSONResponseParser {
        public private(set) var dictionary: JSONDictionary?
        
        public override init() {
            super.init()
        }
        
        open override func parse(_ data: Any) throws {
            guard let dictionary = data as? JSONDictionary else {
                throw CodeError.cantParseNetworkResponse
            }
            
            self.dictionary = dictionary
            
            try parse(dictionary)
        }
        
        open func parse(_ data: JSONDictionary) throws {
            //
        }
    }
    
    open class JSONArrayResponseParser: JSONResponseParser {
        public private(set) var array: JSONArray?
        
        public override init() {
            super.init()
        }
        
        open override func parse(_ data: Any) throws {
            guard let array = data as? JSONArray else {
                throw CodeError.cantParseNetworkResponse
            }
            
            self.array = array
            
            try parse(array)
        }
        
        open func parse(_ data: JSONArray) throws {
            //
        }
    }
}
