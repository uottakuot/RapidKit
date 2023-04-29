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

extension UIView.AutoresizingMask {
    public static let full: Self = [Self.flexibleWidth, Self.flexibleHeight, Self.flexibleTopMargin, Self.flexibleBottomMargin, Self.flexibleLeftMargin, Self.flexibleRightMargin]
}

// In-place activity indicator support.
extension UIView {
    private static var activityIndicatorProperty = "__rk_activityIndicator"
    
    private var activityIndicator: UIActivityIndicatorView? {
        return value(associatedWithKey: &Self.activityIndicatorProperty) as? UIActivityIndicatorView
    }
    
    public func showActivity(_ style: UIActivityIndicatorView.Style) {
        guard superview != nil && activityIndicator == nil else {
            activityIndicator?.startAnimating()
            return
        }
        
        let indicator = UIActivityIndicatorView(style: style)
        indicator.center = center
        indicator.startAnimating()
        superview?.addSubview(indicator)
        
        setValue(indicator, associatedWithKey: &Self.activityIndicatorProperty)
        
        alpha = 0
    }
    
    public func hideActivity() {
        guard superview != nil, let activityIndicator = activityIndicator else {
            return
        }
        
        activityIndicator.removeFromSuperview()
        setValue(nil, associatedWithKey: &Self.activityIndicatorProperty)
        
        alpha = 1
    }
}

extension UIView {
    public var firstResponder: UIView? {
        if isFirstResponder {
            return self
        }
        
        for subview in subviews {
            if let responder = subview.firstResponder {
                return responder
            }
        }
        
        return nil
    }
}
