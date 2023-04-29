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

public class ActivityHUD: UIView {
    private static let indicatorTextInterval: CGFloat = 10
    
    public let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    public let textLabel = UILabel()
    
    public var contentInsets = UIEdgeInsets(all: 20)
    
    public var maxSize = CGSize(width: 250.0, height: .greatestFiniteMagnitude)
    
    public var cornerRadius: CGFloat = 10
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    public init() {
        super.init(frame: .zero)
        
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let constraints = CGSize(width: size.width - contentInsets.left - contentInsets.right,
                                 height: size.height - contentInsets.top - contentInsets.bottom)
        var resultSize = CGSize()
        
        if !activityIndicator.isHidden {
            activityIndicator.sizeToFit()
            
            let indicatorFrame = activityIndicator.frame
            resultSize.width = indicatorFrame.size.width
            resultSize.height += indicatorFrame.size.height
        }
        
        if let text = textLabel.text, let font = textLabel.font {
            let textSize = text.boundingRect(with: constraints, attributes: [.font: font]).size
            resultSize.width = max(resultSize.width, textSize.width)
            resultSize.height += textSize.height
        }
        
        if !activityIndicator.isHidden, !textLabel.isHidden, let text = textLabel.text, text.count > 0 {
            resultSize.height += Self.indicatorTextInterval
        }
        
        resultSize.width += contentInsets.left + contentInsets.right
        resultSize.height += contentInsets.top + contentInsets.bottom
        
        if resultSize.width < resultSize.height {
            resultSize.width = resultSize.height
        }
        
        resultSize.roundCeil()
        
        return resultSize
    }
    
    public override func sizeToFit() {
        var newFrame = frame
        newFrame.size = sizeThatFits(maxSize)
        frame = newFrame
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var y = contentInsets.top
        
        if !activityIndicator.isHidden {
            var indicatorFrame = activityIndicator.frame
            indicatorFrame.origin.x = rint((bounds.size.width - indicatorFrame.size.width) / 2)
            indicatorFrame.origin.y = y
            activityIndicator.frame = indicatorFrame
            
            y += indicatorFrame.size.height + Self.indicatorTextInterval
        }
        
        if !textLabel.isHidden, let text = textLabel.text, let font = textLabel.font {
            let textConstaints = CGSize(width: bounds.size.width - contentInsets.left - contentInsets.right, height: .greatestFiniteMagnitude)
            let textSize = text.boundingRect(with: textConstaints, attributes: [.font: font]).size
            textLabel.frame = CGRect(origin: CGPoint(x: rint((bounds.size.width - textSize.width) / 2), y: y), size: textSize)
        }
        
        effectView.frame = bounds
        sendSubviewToBack(effectView)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.mask = maskLayer
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        }
    }
    
    public func updateFrameInBounds(_ bounds: CGRect) {
        sizeToFit()
        
        var newFrame = frame
        newFrame.origin.x = rint((bounds.size.width - newFrame.size.width) / 2)
        newFrame.origin.y = rint((bounds.size.height - newFrame.size.height) / 2)
        frame = newFrame
    }
    
    private func commonInit() {
        backgroundColor = .white
        
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        
        textLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        textLabel.textColor = .gray
        addSubview(textLabel)
        
        addSubview(effectView)
    }
    
    @objc
    private func deviceDidRotate(_ notification: Notification) {
        if let view = superview {
            updateFrameInBounds(view.bounds)
        }
    }
}
