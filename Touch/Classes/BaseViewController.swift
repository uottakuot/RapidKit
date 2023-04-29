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

open class BaseViewController: UIViewController {
    public private(set) var isViewVisible = false
    
    open var hasData: Bool {
        return true
    }
    
    open var noDataText: String? {
        return nil
    }
    
    open var noDataContainer: UIView {
        return view
    }
    
    public lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var needsRefreshView = false
    
    private var shouldRefreshWithAnimation = false
    
    private var isViewBecomingVisible = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isViewBecomingVisible = true
        
        if needsRefreshView {
            refreshViewInternal()
            needsRefreshView = false
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isViewBecomingVisible = false
        isViewVisible = true
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewBecomingVisible = false
        isViewVisible = false
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasData && !noDataText.isEmptyOrNil {
            noDataLabel.frame = noDataContainer.bounds.insetBy(dx: 15, dy: 0)
        }
    }
    
    open func refreshView(animated: Bool = false) {
        //
    }
    
    public func setNeedsRefreshView(afterDelay delay: TimeInterval = 0, animated: Bool = false) {
        shouldRefreshWithAnimation = animated
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshViewInternal), object: nil)
        
        if !isViewLoaded || !isViewVisible && !isViewBecomingVisible {
            needsRefreshView = true
        } else {
            perform(#selector(refreshViewInternal), with: nil, afterDelay: delay)
        }
    }
    
    public func refreshNoDataInfo() {
        if hasData {
            noDataLabel.removeFromSuperview()
        } else if let text = noDataText {
            if noDataLabel.superview == nil {
                noDataContainer.addSubview(noDataLabel)
            }
            
            noDataLabel.text = text
            
            view.setNeedsLayout()
        }
    }
    
    open func reloadData(completion: (() -> Void)? = nil) {
        setNeedsRefreshView()
        
        completion?()
    }
    
    @objc
    private func refreshViewInternal() {
        refreshView(animated: shouldRefreshWithAnimation)
        shouldRefreshWithAnimation = false
    }
}
