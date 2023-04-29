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

/// Skin class for using with UIButton instances.
open class ButtonSkin: Skin {
    public static func copy(_ source: ButtonSkin, to destination: ButtonSkin) {
        super.copy(source, to: destination)
        
        destination.titleSkin = source.titleSkin?.copy()
        destination.backgroundImages = source.backgroundImages
    }
    
    public var titleSkin: TextSkin?
    
    public var backgroundImages: [UIControl.State: UIImage] = [:]
    
    public override func apply(to view: UIView) {
        super.apply(to: view)
        
        guard let button = view as? UIButton else {
            return
        }
        
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        
        button.titleLabel?.skin = titleSkin
        
        if tintColor == nil {
            button.setTitleColor(titleSkin?.textColors[.normal], for: .normal)
            button.setTitleColor(titleSkin?.textColors[.highlighted], for: .highlighted)
            button.setTitleColor(titleSkin?.textColors[.selected], for: .selected)
            button.setTitleColor(titleSkin?.textColors[.disabled], for: .disabled)
        }
        
        button.setBackgroundColor(backgroundColors[.normal], for: .normal)
        button.setBackgroundColor(backgroundColors[.highlighted], for: .highlighted)
        button.setBackgroundColor(backgroundColors[.selected], for: .selected)
        button.setBackgroundColor(backgroundColors[.disabled], for: .disabled)
        
        button.setBackgroundImage(backgroundImages[.normal], for: .normal)
        button.setBackgroundImage(backgroundImages[.highlighted], for: .highlighted)
        button.setBackgroundImage(backgroundImages[.selected], for: .selected)
        button.setBackgroundImage(backgroundImages[.disabled], for: .disabled)
        
        button.setBorderColor(borderColors[.normal], for: .normal)
        button.setBorderColor(borderColors[.highlighted], for: .highlighted)
        button.setBorderColor(borderColors[.selected], for: .selected)
        button.setBorderColor(borderColors[.disabled], for: .disabled)
    }
    
    public override func copy() -> Self {
        let skin = Self.init()
        Self.copy(self, to: skin)
        return skin
    }
}
