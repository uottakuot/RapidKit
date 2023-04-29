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

extension UIButton {
    private static var backgroundColorsProperty = "__rk_backgroundColors"
    
    private static var borderColorsProperty = "__rk_borderColors"
    
    @objc
    private var rk_isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            let wasSelected = isSelected
            
            super.isHighlighted = newValue
            
            if newValue {
                if let color = backgroundColor(for: .highlighted) {
                    backgroundColor = color
                }
                if let color = borderColor(for: .highlighted) {
                    layer.borderColor = color.cgColor
                }
            } else {
                backgroundColor = backgroundColor(for: wasSelected ? .selected : .normal)
                layer.borderColor = borderColor(for: wasSelected ? .selected : .normal)?.cgColor
            }
            
            titleLabel?.setNeedsDisplay()
            imageView?.setNeedsDisplay()
        }
    }
    
    @objc
    private var rk_isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            
            if newValue {
                if let color = backgroundColor(for: .selected) {
                    backgroundColor = color
                }
                if let color = borderColor(for: .selected) {
                    layer.borderColor = color.cgColor
                }
            } else {
                backgroundColor = backgroundColor(for: .normal)
                layer.borderColor = borderColor(for: .normal)?.cgColor
            }
            
            titleLabel?.setNeedsDisplay()
            imageView?.setNeedsDisplay()
        }
    }
    
    @objc
    private var rk_isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            
            if !newValue {
                if let color = backgroundColor(for: .disabled) {
                    backgroundColor = color
                }
                if let color = borderColor(for: .disabled) {
                    layer.borderColor = color.cgColor
                }
                if let image = image(for: .disabled) {
                    imageView?.image = image
                }
            } else {
                backgroundColor = backgroundColor(for: .normal)
                layer.borderColor = borderColor(for: .normal)?.cgColor
                imageView?.image = image(for: .normal)
            }
            
            titleLabel?.setNeedsDisplay()
            imageView?.setNeedsDisplay()
        }
    }
    
    public func backgroundColor(for state: UIControl.State) -> UIColor? {
        let colors = value(associatedWithKey: &Self.backgroundColorsProperty) as? [UInt: UIColor]
        return colors?[state.rawValue]
    }
    
    public func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        applyCustomClass()
        
        var colors = value(associatedWithKey: &Self.backgroundColorsProperty) as? [UInt: UIColor] ?? [:]
        colors[state.rawValue] = color
        setValue(colors, associatedWithKey: &Self.backgroundColorsProperty)
        
        if state == .normal {
            backgroundColor = color
        }
        
        setNeedsDisplay()
    }
    
    public func borderColor(for state: UIControl.State) -> UIColor? {
        let colors = value(associatedWithKey: &Self.borderColorsProperty) as? [UInt: UIColor]
        return colors?[state.rawValue]
    }
    
    public func setBorderColor(_ color: UIColor?, for state: UIControl.State) {
        applyCustomClass()
        
        var colors = value(associatedWithKey: &Self.borderColorsProperty) as? [UInt: UIColor] ?? [:]
        colors[state.rawValue] = color
        setValue(colors, associatedWithKey: &Self.borderColorsProperty)
        
        if state == .normal {
            layer.borderColor = color?.cgColor
        }
        
        setNeedsDisplay()
    }
    
    private func applyCustomClass() {
        setClass(withPrefix: "RK", suffix: "TouchExtensions") { subclass in
            subclass.replaceInstanceMethodImplementation(for: #selector(setter: isHighlighted), with: #selector(setter: rk_isHighlighted))
            subclass.replaceInstanceMethodImplementation(for: #selector(setter: isSelected), with: #selector(setter: rk_isSelected))
            subclass.replaceInstanceMethodImplementation(for: #selector(setter: isEnabled), with: #selector(setter: rk_isEnabled))
        }
    }
}
