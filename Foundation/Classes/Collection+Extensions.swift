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

extension Collection where Element: AnyObject {
    public func firstIndex(of item: Element) -> Index? {
        return firstIndex { $0 === item }
    }
    
    public func element(before element: Element, inCycle: Bool = false) -> Element? {
        guard let indexAfter = firstIndex(of: element) else {
            return nil
        }
        
        guard let index = index(indexAfter, offsetBy: -1, limitedBy: startIndex) else {
            return inCycle ? self[index(endIndex, offsetBy: -1)] : nil
        }
        
        return self[index]
    }
    
    public func element(after element: Element, inCycle: Bool = false) -> Element? {
        guard let indexBefore = firstIndex(of: element) else {
            return nil
        }
        
        guard let index = index(indexBefore, offsetBy: 1, limitedBy: index(endIndex, offsetBy: -1)) else {
            return inCycle ? self[startIndex] : nil
        }
        
        return self[index]
    }
}

extension Collection where Element: Equatable {
    public func firstIndex(of item: Element) -> Index? {
        return firstIndex { $0 == item}
    }
}

extension Optional where Wrapped: Collection {
    public var isEmptyOrNil: Bool {
        return self?.isEmpty ?? true
    }
}
