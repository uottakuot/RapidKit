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

extension UIImage {
    public var isOpaque: Bool {
        guard let info = cgImage?.alphaInfo else {
            return true
        }
        
        return !(info == .alphaOnly || info == .first || info == .last || info == .premultipliedFirst || info == .premultipliedLast)
    }
    
    public func scaled(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let ratio = min(newSize.width / size.width, newSize.height / size.height)
        let drawSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let drawOrigin = CGPoint(x: rint((newSize.width - drawSize.width) / 2), y: rint((newSize.height - drawSize.height) / 2))
        draw(in: CGRect(origin: drawOrigin, size: drawSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func cropped(to rect: CGRect, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Replacement for "withTintColor()" from iOS 13.0 on older versions.
    public func tinted(with color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setBlendMode(.normal)
        draw(in: rect)
        context.setBlendMode(.sourceIn)
        color.setFill()
        context.fill(rect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
