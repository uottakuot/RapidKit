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

public protocol CustomTableViewCellDelegate: AnyObject {
    func customTableViewCellDidLayoutSubviews(_ cell: CustomTableViewCell)
}

/// Cell class for using in TableViewController along with TableViewCellSource.
open class CustomTableViewCell: UITableViewCell {
    public weak var delegate: CustomTableViewCellDelegate?
    
    public var customContentView: UIView? {
        willSet {
            customContentView?.removeFromSuperview()
        }
        didSet {
            if let view = customContentView {
                contentView.addSubview(view)
            }
            
            setNeedsLayout()
        }
    }
    
    public var customContentViewInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public let topLineView = LineView()
    
    public var topLineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var topLineInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public let bottomLineView = LineView()
    
    public var bottomLineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var bottomLineInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let customView = customContentView {
            var frame = contentView.bounds
            frame.origin.x = customContentViewInsets.left
            frame.origin.y = customContentViewInsets.top
            frame.size.width -= customContentViewInsets.left + customContentViewInsets.right
            frame.size.height -= customContentViewInsets.top + customContentViewInsets.bottom
            
            customView.frame = frame
        }
        
        topLineView.frame = CGRect(x: topLineInsets.left, y: 0, width: bounds.size.width - topLineInsets.left - topLineInsets.right, height: topLineWidth)
        bottomLineView.frame = CGRect(x: bottomLineInsets.left, y: bounds.size.height - bottomLineWidth, width: bounds.size.width - bottomLineInsets.left - bottomLineInsets.right, height: bottomLineWidth)
        
        bringSubviewToFront(topLineView)
        bringSubviewToFront(bottomLineView)
        
        if (isHighlighted || isSelected), let selectedBackgroundView = selectedBackgroundView {
            var frame = selectedBackgroundView.frame
            frame.origin.y = 0
            frame.size.height = bounds.size.height
            
            selectedBackgroundView.frame = frame
        }
        
        delegate?.customTableViewCellDidLayoutSubviews(self)
    }
    
    private func commonInit() {
        topLineView.isHidden = true
        addSubview(topLineView)
        
        bottomLineView.isHidden = true
        addSubview(bottomLineView)
    }
}
