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

/// Cell information for creating and managing cells in TableViewController.
/// Contains all cell parameters including event handlers.
public class TableViewCellSource {
    public struct CallbackInfo {
        public let controller: TableViewController
        
        public let indexPath: IndexPath
        
        public let cellSource: TableViewCellSource
        
        public let cell: CustomTableViewCell?
    }
    
    public typealias Callback = (_ info: CallbackInfo) -> Void
    
    public var reuseIdentifier: String?
    
    public var cellClass: CustomTableViewCell.Type?
    
    public var cellStyle: UITableViewCell.CellStyle = .default
    
    public var accessoryType: UITableViewCell.AccessoryType = .none
    
    public var accessoryView: UIView?
    
    public var editingAccessoryType: UITableViewCell.AccessoryType = .none
    
    public var editingAccessoryView: UIView?
    
    public var selectionStyle: UITableViewCell.SelectionStyle = .none
    
    public var text: String?
    
    public var detailText: String?
    
    public var image: UIImage?
    
    public var contentView: UIView?
    
    public var contentViewInsets = UIEdgeInsets(vertical: 0, horizontal: 15)
    
    public var usesContentViewHeight = false
    
    public var rowHeight: CGFloat?
    
    public var minRowHeight: CGFloat?
    
    public var showsTopLine = false
    
    public var showsBottomLine = false
    
    public var topLineColor: UIColor?
    
    public var bottomLineColor: UIColor?
    
    public var topLineInsets: UIEdgeInsets = .zero
    
    public var bottomLineInsets: UIEdgeInsets = .zero
    
    public var numberOfTextLines = 1
    
    public var numberOfDetailTextLines = 1
    
    public var cellSkin: Skin?
    
    public var textSkin: TextSkin?
    
    public var detailSkin: TextSkin?
    
    public var imageSkin: Skin?
    
    public var data: Any?
    
    public var userInfo: Any?
    
    public var didCreateCell: Callback?
    
    public var willDisplayCell: Callback?
    
    public var didHighlightCell: Callback?
    
    public var didUnhighlightCell: Callback?
    
    public var didSelectCell: Callback?
    
    public var willCalculateHeight: Callback?
    
    public var willCalculateContentHeight: ((_ info: CallbackInfo, _ constraints: CGSize) -> CGFloat)?
    
    public var didLayoutSubviews: Callback?
    
    public init() {
        //
    }
}

extension TableViewCellSource {
    public convenience init(data: Any?, reuseIdentifier: String? = nil, disclosure: Bool = false) {
        self.init()
        
        self.reuseIdentifier = reuseIdentifier
        self.data = data
        
        if disclosure {
            selectionStyle = .default
            accessoryType = .disclosureIndicator
        }
    }
    
    
    public convenience init(text: String?, image: UIImage? = nil, disclosure: Bool = false) {
        self.init()
        
        self.text = text
        self.image = image
        
        if disclosure {
            selectionStyle = .default
            accessoryType = .disclosureIndicator
        }
    }
    
    public convenience init(contentView: UIView?) {
        self.init()
        
        self.contentView = contentView
    }
}
