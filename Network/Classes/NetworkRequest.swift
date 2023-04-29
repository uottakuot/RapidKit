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

extension Network {
    public enum Method: String {
        case get = "GET"
        
        case post = "POST"
        
        case put = "PUT"
        
        case delete = "DELETE"
        
        case options = "OPTIONS"
    }
    
    public struct MultipartForm {
        public let name: String
        
        public let fileName: String?
        
        public let contentType: MIMEType
        
        public let contentLength: Int
        
        public let data: Data
        
        public init(name: String, fileName: String?, contentType: MIMEType, contentLength: Int, data: Data) {
            self.name = name
            self.fileName = fileName
            self.contentType = contentType
            self.contentLength = contentLength
            self.data = data
        }
    }
    
    /// Structure containing the initial information about an HTTP-request including an instance of NetworkResponseParser for parsing response.
    public struct Request<Parser: NetworkResponseParser> {
        public let url: URL
        
        public let path: String?
        
        public let method: Method
        
        public var headers: [String: String] = [:]
        
        public var postValues: [String: String] = [:]
        
        public var queryValues: [String: String] = [:]
        
        public var postBody: Data?
        
        public var multipartForms: [MultipartForm] = []
        
        public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
        
        public var timeout: TimeInterval = 30
        
        public var finalURL: URL? {
            var finalURL = url
            
            if let path = path {
                finalURL = finalURL.appendingPathComponent(path)
            }
            
            guard queryValues.count > 0, var components = URLComponents(url: finalURL, resolvingAgainstBaseURL: false) else {
                return finalURL
            }
            
            components.queryItems = queryValues.map { URLQueryItem(name: $0, value: $1) }
            
            return components.url
        }
        
        public let parser: Parser
        
        public init(url: URL, path: String? = nil, method: Method, contentType: MIMEType? = nil, parser: Parser) {
            self.url = url
            self.path = path
            self.method = method
            self.parser = parser
            
            if let contentType = contentType {
                headers["Content-Type"] = contentType.rawValue
            }
        }
    }
}
