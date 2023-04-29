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

/// Skin class for using with UINavigationBar instances.
open class NavigationBarSkin: Skin {
    private static let lineViewTag = 1000
    
    public static func copy(_ source: NavigationBarSkin, to destination: NavigationBarSkin) {
        super.copy(source, to: destination)
        
        destination.titleSkin = source.titleSkin?.copy()
        destination.contentTintColor = source.contentTintColor
        destination.backIndicatorImage = source.backIndicatorImage
        destination.backIndicatorTransitionMaskImage = source.backIndicatorTransitionMaskImage
        destination.isTranslucent = source.isTranslucent
        destination.statusBarStyle = source.statusBarStyle
        destination.hidesSystemBottomLine = source.hidesSystemBottomLine
        destination.prefersLargeTitle = source.prefersLargeTitle
    }
    
    public var titleSkin: TextSkin?
    
    public var backIndicatorImage: UIImage?
    
    public var backIndicatorTransitionMaskImage: UIImage?
    
    public var contentTintColor: UIColor?
    
    public var isTranslucent: Bool?
    
    public var statusBarStyle: UIStatusBarStyle?
    
    public var prefersLargeTitle: Bool?
    
    public var hidesSystemBottomLine = false
    
    public override func apply(to view: UIView) {
        super.apply(to: view)
        
        guard let navBar = view as? UINavigationBar else {
            return
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            if isTranslucent == nil || isTranslucent! {
                appearance.configureWithDefaultBackground()
            } else {
                appearance.configureWithOpaqueBackground()
            }
            appearance.backgroundColor = backgroundColors[.normal]
            if let titleAttributes = titleSkin?.textAttributes {
                appearance.titleTextAttributes = titleAttributes
            }
            appearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorTransitionMaskImage)
            appearance.shadowColor = hidesSystemBottomLine ? nil : borderColors[.normal]
            
            navBar.standardAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
        } else {
            navBar.barStyle = .black
            if let isTranslucent = isTranslucent {
                navBar.isTranslucent = isTranslucent
            }
            navBar.titleTextAttributes = titleSkin?.textAttributes
            navBar.backIndicatorImage = backIndicatorImage
            navBar.backIndicatorTransitionMaskImage = backIndicatorTransitionMaskImage
            
            if let borderColor = borderColors[.normal], let borderWidth = borderWidth {
                let borderView = navBar.viewWithTag(Self.lineViewTag) ?? {
                    let borderView = UIView(frame: CGRect(x: 0, y: navBar.frame.size.height - borderWidth + 1, width: navBar.frame.size.width, height: borderWidth))
                    navBar.addSubview(borderView)
                    return borderView
                }()
                
                borderView.backgroundColor = borderColor
                navBar.bringSubviewToFront(borderView)
            }
        }
        
        if #available(iOS 11.0, *) {
            if let prefersLargeTitle = prefersLargeTitle {
                navBar.prefersLargeTitles = prefersLargeTitle
            }
        }
        
        navBar.tintColor = contentTintColor
        navBar.layer.borderWidth = 0
    }
    
    public override func copy() -> Self {
        let skin = Self.init()
        Self.copy(self, to: skin)
        return skin
    }
}
