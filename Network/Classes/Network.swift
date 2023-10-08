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

public protocol NetworkDelegate: AnyObject {
    func network(_ network: Network, didStartRequestWithID id: Network.RequestID)
    
    func network(_ network: Network, didFinishRequestWithID id: Network.RequestID)
    
    func network(_ network: Network, errorFromResponseData data: Data) -> Error?
    
    func network(_ network: Network, didReceiveError error: Error)
}

extension NetworkDelegate {
    public func network(_ network: Network, didStartRequestWithID id: Network.RequestID) {
        //
    }
    
    public func network(_ network: Network, didFinishRequestWithID id: Network.RequestID) {
        //
    }
    
    public func network(_ network: Network, errorFromResponseData data: Data) -> Error? {
        return nil
    }
    
    public func network(_ network: Network, didReceiveError error: Error) {
        //
    }
}

/// Class for network tasks that lets:
/// - execute and manage requests
/// - monitor reachability
/// - parse error from responses
public class Network {
    public typealias RequestID = String
    
    public enum ReachabilityStatus {
        case none
        
        case wifi
        
        case cellular
    }
    
    public struct Configuration {
        public let baseURL: URL
        
        public var httpMaximumConnectionsPerHost = 6
        
        public var allowsCellular = true
        
        public init(baseURL: URL) {
            self.baseURL = baseURL
        }
    }
    
    public struct Option: OptionSet {
        public let rawValue: Int
        
        public static let backgroundCallback = Self(rawValue: 1 << 0)
        
        public static let suppressError = Self(rawValue: 1 << 1)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public enum Logging {
        case none
        
        case verbose
    }
    
    public static let reachabilityDidChangeNotification = Notification.Name("com.uottakuot.rapidkit.network.reachabilityDidChangeNotification")
    
    public static var reachabilityStatus: ReachabilityStatus {
        switch reachability.currentReachabilityStatus().rawValue {
            case 1:
                return .wifi
                
            case 2:
                return .cellular
            
            default:
                return .none
        }
    }
    
    private static let reachability: Reachability = .forInternetConnection()
    
    public class func startMonitoringReachability() {
        reachability.startNotifier()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: Notification.Name(kReachabilityChangedNotification), object: nil)
    }
    
    public class func stopMonitoringReachability() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kReachabilityChangedNotification), object: nil)
        
        reachability.stopNotifier()
    }
    
    public weak var delegate: NetworkDelegate?
    
    public let configuration: Configuration
    
    public var logging: Logging = .none
    
    private let session: URLSession
    
    private var tasks: [RequestID: URLSessionTask] = [:]
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = configuration.httpMaximumConnectionsPerHost
        sessionConfiguration.allowsCellularAccess = configuration.allowsCellular
        
        session = URLSession(configuration: sessionConfiguration)
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    @discardableResult
    public func execute<Parser: NetworkResponseParser>(_ request: Request<Parser>, options: Option = [], completion: @escaping (Parser, Error?) -> Void) -> RequestID? {
        let fail = { (error: Error) -> Void in
            self.delegate?.network(self, didReceiveError: error)
            completion(request.parser, error)
        }
        
        guard Self.reachabilityStatus != .none else {
            DispatchQueue.main.async {
                fail(CodeError.noNetworkConnection)
            }
            
            return nil
        }
        
        guard let urlRequest = urlRequestFromRequest(request) else {
            DispatchQueue.main.async {
                fail(CodeError.cantCreateNetworkRequest)
            }
            
            return nil
        }
        
        let requestID = UUID().uuidString
        
        delegate?.network(self, didStartRequestWithID: requestID)
        
        if logging == .verbose {
            let string = """
            Request started:
            url: \(urlRequest.httpMethod ?? "") \(urlRequest.url!.absoluteString)
            body: \(urlRequest.httpBody != nil ? String(data: urlRequest.httpBody!, encoding: .utf8) ?? "<not a string>" : "nil")
            """
            print(string)
        }
        
        let requestCompletion = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            let parser = request.parser
            
            if self.logging == .verbose, let response = response {
                let string = """
                Request finished:
                response: \(response))
                """
                print(string)
            }
            
            let dispatchCompletion = { (error: Error?) -> Void in
                if self.logging == .verbose, let error = error {
                    print("Error: \(error.localizedDescription)")
                    
                    if let codeError = error as? CodeError {
                        print("Error codes: \(codeError.codes)")
                    }
                }
                
                let queue = options.contains(.backgroundCallback) ? DispatchQueue.global(qos: .background) : DispatchQueue.main
                queue.async {
                    if let error = error {
                        fail(error)
                    } else {
                        completion(parser, nil)
                    }
                }
            }
            
            let resultError = self.error(from: response, data: data, error: error)
            guard resultError == nil else {
                dispatchCompletion(resultError)
                return
            }
            
            guard let responseData = data, responseData.count > 0 else {
                dispatchCompletion(nil)
                return
            }
            
            if self.logging == .verbose, let string = String(data: responseData, encoding: .utf8) {
                print("Response: \(string)")
            }
            
            do {
                try parser.parse(responseData)
                dispatchCompletion(nil)
            } catch {
                dispatchCompletion(error)
            }
        }
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            synchronized(self) {
                self.tasks[requestID] = nil
            }
            
            self.delegate?.network(self, didFinishRequestWithID: requestID)
            
            requestCompletion(data, response, error)
        }
        
        synchronized(self) {
            tasks[requestID] = task
        }
        
        task.resume()
        
        return requestID
    }
    
    public func suspendRequest(withID id: RequestID) {
        synchronized(self) {
            if let task = tasks[id] {
                task.suspend()
            }
        }
    }
    
    public func resumeRequest(withID id: RequestID) {
        synchronized(self) {
            if let task = tasks[id] {
                task.resume()
            }
        }
    }
    
    public func cancelRequest(withID id: RequestID) {
        synchronized(self) {
            if let task = tasks[id] {
                task.cancel()
                tasks[id] = nil
            }
        }
    }
    
    @objc
    private class func reachabilityDidChange(_ notification: Notification) {
        NotificationCenter.default.post(name: reachabilityDidChangeNotification, object: nil)
    }
    
    private func urlRequestFromRequest<Parser: NetworkResponseParser>(_ request: Request<Parser>) -> URLRequest? {
        guard let url = request.finalURL else {
            return nil
        }
        
        let urlRequest = NSMutableURLRequest(url: url, cachePolicy: request.cachePolicy, timeoutInterval: request.timeout)
        urlRequest.httpMethod = request.method.rawValue
        
        var headers = request.headers
        
        if request.postValues.count > 0 {
            let charset = CFStringConvertEncodingToIANACharSetName(CFStringBuiltInEncodings.UTF8.rawValue) as String
            headers["Content-Type"] = "application/x-www-form-urlencoded; charset=\(charset)"
            
            var postString = ""
            for (key, value) in request.postValues {
                guard let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    continue
                }
                
                if postString.count > 0 {
                    postString.append("&")
                }
                
                postString.append("\(key)=\(value)")
            }
            
            urlRequest.httpBody = postString.data(using: .utf8)
        } else if request.multipartForms.count > 0 {
            var postBody = Data()
            
            let appendLine = { (addition: Any) -> Void in
                let lineData: Data? = {
                    if let stringAddition = addition as? String {
                        return stringAddition.data(using: .utf8)
                    } else if let dataAddition = addition as? Data {
                        return dataAddition
                    }
                    return nil
                }()
                
                if let lineData = lineData {
                    postBody.append(lineData)
                    postBody.append("\r\n".data(using: .utf8)!)
                }
            }
            
            let boundary = UUID().uuidString
            headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
            
            for form in request.multipartForms {
                appendLine("--" + boundary)
                
                if let fileName = form.fileName {
                    appendLine("Content-Disposition: form-data; name=\"\(form.name)\"; filename=\"\(fileName)\"")
                } else {
                    appendLine("Content-Disposition: form-data; name=\"\(form.name)\"")
                }
                
                appendLine("Content-Type: \(form.contentType)")
                appendLine("Content-Length: \(form.contentLength)")
                appendLine("")
                appendLine(form.data)
            }
            
            appendLine("--\(boundary)--")
            
            urlRequest.httpBody = postBody
        } else {
            urlRequest.httpBody = request.postBody
        }
        
        urlRequest.allHTTPHeaderFields = headers
        
        return urlRequest as URLRequest
    }
    
    private func error(from response: URLResponse?, data: Data?, error: Error?) -> Error? {
        var errorMessage: String?
        var errorCodes: [Int] = []
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode >= 400 {
                errorCodes.append(response.statusCode)
            }
        }
        
        if let data = data, let errorFromResponse = delegate?.network(self, errorFromResponseData: data) {
            if let codeError = errorFromResponse as? CodeError {
                errorCodes.append(contentsOf: codeError.codes)
                errorMessage = codeError.localizedDescription
            } else {
                let code = (errorFromResponse as NSError).code
                errorCodes.append(code)
                errorMessage = (errorFromResponse as NSError).localizedDescription
            }
        }
        
        if let error = error {
            if errorMessage == nil {
                errorMessage = error.localizedDescription
            }
            
            if errorCodes.isEmpty {
                errorCodes.append((error as NSError).code)
            }
        }
        
        if !errorCodes.isEmpty {
            return CodeError(errorCodes, description: errorMessage)
        }
        
        return nil
    }
}
