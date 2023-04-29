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

/// Skin class for using with UITableView instances.
public class TableSkin: Skin {
    public static func copy(_ source: TableSkin, to destination: TableSkin) {
        super.copy(source, to: destination)
        
        destination.separatorStyle = source.separatorStyle
        destination.separatorColor = source.separatorColor
        destination.separatorInsets = source.separatorInsets
    }
    
    public var separatorStyle: UITableViewCell.SeparatorStyle?
    
    public var separatorColor: UIColor?
    
    public var separatorInsets: UIEdgeInsets?
    
    public override func apply(to view: UIView) {
        super.apply(to: view)
        
        guard let table = view as? UITableView else {
            return
        }
        
        if let separatorStyle = separatorStyle {
            table.separatorStyle = separatorStyle
        }
        
        table.separatorColor = separatorColor
        
        if let separatorInsets = separatorInsets {
            table.separatorInset = separatorInsets
        }
    }
    
    public override func copy() -> Self {
        let skin = Self.init()
        Self.copy(self, to: skin)
        return skin
    }
}
