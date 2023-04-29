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

import UIKit

/// Skin class for using with UILabel, UITextField or UITextView instances.
public class TextSkin: Skin {
    public static func copy(_ source: TextSkin, to destination: TextSkin) {
        super.copy(source, to: destination)
        
        destination.font = source.font
        destination.textColors = source.textColors
        destination.textInsets = source.textInsets
        destination.textAlignment = source.textAlignment
    }
    
    public var font: UIFont?
    
    public var textColors: [UIControl.State: UIColor] = [:]
    
    public var textInsets: UIEdgeInsets?
    
    public var textAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = font
        attributes[.foregroundColor] = textColors[.normal]
        
        return attributes
    }
    
    public var textAlignment: NSTextAlignment?
    
    public override func apply(to view: UIView) {
        super.apply(to: view)
        
        if let label = view as? UILabel {
            if let font = font {
                label.font = font
            }
            if let textColor = textColors[.normal] {
                label.textColor = textColor
            }
            label.highlightedTextColor = textColors[.highlighted]
            if let textAlignment = textAlignment {
                label.textAlignment = textAlignment
            }
        } else if let field = view as? UITextField {
            field.font = font
            field.textColor = textColors[.normal]
            field.textInsets = textInsets
            if let textAlignment = textAlignment {
                field.textAlignment = textAlignment
            }
        } else if let textView = view as? UITextView {
            textView.font = font
            textView.textColor = textColors[.normal]
            if let textInsets = textInsets {
                textView.textContainerInset = textInsets
            }
            if let textAlignment = textAlignment {
                textView.textAlignment = textAlignment
            }
        }
    }
    
    public override func copy() -> Self {
        let skin = Self.init()
        Self.copy(self, to: skin)
        return skin
    }
}
