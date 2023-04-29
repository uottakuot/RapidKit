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

import RapidFoundation
import UIKit

extension UITextField {
    private static var textInsetsProperty = "__rk_textInsets"
    
    public var textInsets: UIEdgeInsets? {
        get {
            return value(associatedWithKey: &Self.textInsetsProperty) as? UIEdgeInsets
        }
        set {
            let hasValue = value(associatedWithKey: &Self.textInsetsProperty) as? UIEdgeInsets != nil
            if newValue != nil || hasValue {
                applyCustomClass()
                setValue(newValue, associatedWithKey: &Self.textInsetsProperty)
            }
        }
    }
    
    @objc
    private func rk_textRect(forBounds bounds: CGRect) -> CGRect {
        guard let textInsets = textInsets else {
            return .zero
        }
        
        let leftViewFrame = leftView?.frame ?? .zero
        let rightViewFrame = rightView?.frame ?? .zero
        
        var rect = bounds
        rect.origin.x = textInsets.left + leftViewFrame.origin.x + leftViewFrame.size.width
        rect.origin.y = textInsets.top
        rect.size.width -= textInsets.left + textInsets.right + leftViewFrame.origin.x + leftViewFrame.size.width + rightViewFrame.size.width
        rect.size.height -= textInsets.top + textInsets.bottom
        
        return rect
    }
    
    private func applyCustomClass() {
        setClass(withPrefix: "RK", suffix: "TouchExtensions") { subclass in
            subclass.replaceInstanceMethodImplementation(for: #selector(textRect(forBounds:)), with: #selector(rk_textRect(forBounds:)))
            subclass.replaceInstanceMethodImplementation(for: #selector(editingRect(forBounds:)), with: #selector(rk_textRect(forBounds:)))
        }
    }
}
