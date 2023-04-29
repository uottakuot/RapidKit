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

extension Bundle {
    public struct VersionType: OptionSet {
        public let rawValue: Int
        
        public static let display = Self(rawValue: 1 << 0)
        
        public static let build = Self(rawValue: 1 << 1)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public func formattedVersion(_ type: VersionType, format: String? = nil) -> String? {
        var versions: [String] = []
        
        if type.contains(.display), let version = infoDictionary?["CFBundleShortVersionString"] as? String {
            versions.append(version)
        }
        
        if type.contains(.build), let version = infoDictionary?["CFBundleVersion"] as? String {
            versions.append(version)
        }
        
        if !versions.isEmpty, let format = format {
            return String(format: format, arguments: versions)
        }
        
        if versions.count == 2 {
            return "\(versions[0]) (\(versions[1]))"
        }
        
        return versions.first
    }
}
