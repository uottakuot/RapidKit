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

extension NSObject {
    private static var objectTagProperty = "__rk_objectTag"
    
    public class func subclass(withPrefix prefix: String, suffix: String, created: inout Bool) -> AnyClass? {
        created = false
        
        guard !prefix.isEmpty && !suffix.isEmpty else {
            return nil
        }
        
        let className = NSStringFromClass(self)
        if className.hasPrefix(prefix) && className.hasSuffix(suffix) {
            return self
        }
        
        let newClassName = "\(prefix)\(className)\(suffix)"
        guard let newClassNameCString = newClassName.cString(using: .ascii) else {
            return nil
        }
        
        let subclass: AnyClass? = objc_getClass(newClassNameCString) as? AnyClass ?? {
            guard let subclass = objc_allocateClassPair(self, newClassNameCString, 0) else {
                return nil
            }
            
            objc_registerClassPair(subclass)
            created = true
            
            return subclass
        }()
        
        return subclass
    }
    
    public class func replaceInstanceMethodImplementation(for selector: Selector, with impSelector: Selector) {
        guard let method = class_getInstanceMethod(self, selector),
              let impMethod = class_getInstanceMethod(self, impSelector),
              let encoding = method_getTypeEncoding(method) else {
            return
        }
        
        let imp = method_getImplementation(impMethod)
        if !class_addMethod(self, selector, imp, encoding) {
            method_setImplementation(method, imp)
        }
    }
    
    public var objectTag: Any? {
        get {
            return value(associatedWithKey: &Self.objectTagProperty)
        }
        set {
            setValue(newValue, associatedWithKey: &Self.objectTagProperty)
        }
    }
    
    public func value(associatedWithKey key: inout String) -> Any? {
        return objc_getAssociatedObject(self, &key)
    }
    
    public func setValue(_ value: Any?, associatedWithKey key: inout String) {
        objc_setAssociatedObject(self, &key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public func repeatPerform(_ selector: Selector, afterDelay delay: TimeInterval) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: nil)
        self.perform(selector, with: nil, afterDelay: delay)
    }
    
    public func setClass(withPrefix prefix: String, suffix: String, initBlock: (_ subclass: NSObject.Type) -> Void) {
        var created = false
        guard let subclass = type(of: self).subclass(withPrefix: prefix, suffix: suffix, created: &created) as? NSObject.Type else {
            return
        }
        
        if created {
            initBlock(subclass)
        }
        
        object_setClass(self, subclass)
    }
}

public func tryObjC(_ block: @escaping () -> Void) throws {
    if let error = RKCatchObjCException(block) {
        throw error
    }
}
