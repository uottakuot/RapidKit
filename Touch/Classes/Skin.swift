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

/// Base class for changing a view's appearance by setting its `skin` property.
/// Works for any UIView.
open class Skin: Copyable {
    public static func copy(_ source: Skin, to destination: Skin) {
        destination.backgroundColors = source.backgroundColors
        destination.isOpaque = source.isOpaque
        destination.clipsToBounds = source.clipsToBounds
        destination.tintColor = source.tintColor
        destination.borderWidth = source.borderWidth
        destination.borderColors = source.borderColors
        destination.cornerRadius = source.cornerRadius
        destination.shadowColor = source.shadowColor
        destination.shadowOpacity = source.shadowOpacity
        destination.shadowRadius = source.shadowRadius
        destination.shadowOffset = source.shadowOffset
    }
    
    public var backgroundColors: [UIControl.State: UIColor] = [:]
    
    public var isOpaque: Bool?
    
    public var clipsToBounds: Bool?
    
    public var tintColor: UIColor?
    
    public var borderWidth: CGFloat?
    
    public var borderColors: [UIControl.State: UIColor] = [:]
    
    public var cornerRadius: CGFloat?
    
    public var shadowColor: UIColor?
    
    public var shadowOpacity: Float?
    
    public var shadowRadius: CGFloat?
    
    public var shadowOffset: CGSize?
    
    public required init() {
        //
    }
    
    open func apply(to view: UIView) {
        if let isOpaque = isOpaque {
            view.isOpaque = isOpaque
        }
        if let tintColor = tintColor {
            view.tintColor = tintColor
        }
        if let borderColor = borderColors[.normal] {
            view.layer.borderColor = borderColor.cgColor
        }
        if let borderWidth = borderWidth {
            view.layer.borderWidth = borderWidth
        }
        if var cornerRadius = cornerRadius {
            let maxRadius = min(view.frame.size.width, view.frame.size.height) / 2
            if cornerRadius > maxRadius {
                cornerRadius = maxRadius
            }
            view.layer.cornerRadius = cornerRadius
        }
        if let shadowColor = shadowColor {
            view.layer.shadowColor = shadowColor.cgColor
        }
        if let shadowOpacity = shadowOpacity {
            view.layer.shadowOpacity = shadowOpacity
        }
        if let shadowRadius = shadowRadius {
            view.layer.shadowRadius = shadowRadius
        }
        if let shadowOffset = shadowOffset {
            view.layer.shadowOffset = shadowOffset
        }
        if let clipsToBounds = clipsToBounds {
            view.clipsToBounds = clipsToBounds
        }
        
        let backgroundColor = backgroundColors[.normal]
        
        if let navBar = view as? UINavigationBar {
            navBar.barTintColor = backgroundColor
        } else if let toolbar = view as? UIToolbar {
            toolbar.barTintColor = backgroundColor
        } else if let label = view as? UILabel {
            if backgroundColor != nil {
                label.backgroundColor = backgroundColor
            }
        } else if let cell = view as? UITableViewCell {
            if let color = backgroundColor {
                let view = UIView()
                view.backgroundColor = color
                cell.backgroundView = view
                cell.backgroundColor = .clear
            } else {
                cell.backgroundView = nil
            }
            
            if let color = backgroundColors[.highlighted] {
                let view = UIView()
                view.backgroundColor = color
                cell.selectedBackgroundView = view
            } else {
                cell.selectedBackgroundView = nil
            }
        } else {
            view.backgroundColor = backgroundColor
        }
    }
    
    open func copy() -> Self {
        let skin = Self.init()
        Self.copy(self, to: skin)
        return skin
    }
}

extension UIView {
    private static var skinProperty = "__rk_skin"
    
    public var skin: Skin? {
        get {
            return value(associatedWithKey: &Self.skinProperty) as? Skin
        }
        set {
            setValue(newValue, associatedWithKey: &Self.skinProperty)
            newValue?.apply(to: self)
        }
    }
}
