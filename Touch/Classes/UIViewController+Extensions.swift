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

extension UIViewController {
    private static var activityHUDProperty = "__rk_activityHUD"
    
    public class func fromDefaultNib() -> Self {
        let availableNibNames = [NSStringFromClass(self), String(describing: self)]
        let existingNibName = availableNibNames.first { Bundle.main.url(forResource: $0, withExtension: "nib") != nil }
        
        return self.init(nibName: existingNibName, bundle: nil)
    }
    
    private var activityHUD: ActivityHUD {
        get {
            return value(associatedWithKey: &Self.activityHUDProperty) as? ActivityHUD ?? {
                let activity = ActivityHUD()
                activity.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
                
                setValue(activity, associatedWithKey: &Self.activityHUDProperty)
                
                return activity
            }()
        }
    }
    
    public func showActivity(text: String? = nil) {
        let activity = activityHUD
        activity.textLabel.text = text
        activity.updateFrameInBounds(view.bounds)
        
        guard activity.superview == nil else {
            return
        }
        
        activity.alpha = 0
        
        view.addSubview(activity)
        
        perform(#selector(showActivityIfNeeded), with: nil, afterDelay: 0.2)
    }
    
    public func hideActivity() {
        let activity = activityHUD
        
        guard activity.superview != nil else {
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showActivityIfNeeded), object: nil)
        
        UIView.animate(withDuration: 0.2) {
            activity.alpha = 0
        } completion: { finished in
            activity.removeFromSuperview()
        }
    }
    
    public func present(alertWithTitle title: String?,
                        message: String?,
                        okTitle: String? = nil,
                        cancelTitle: String? = nil,
                        okAction: (() -> Void)? = nil,
                        cancelAction: (() -> Void)? = nil,
                        cancelPreferred: Bool = true) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let hasOk = okTitle != nil || okAction != nil
        let hasCancel = cancelTitle != nil || cancelAction != nil
        
        if hasOk || !hasCancel {
            let okAction = UIAlertAction(title: okTitle ?? localizedString("OK"), style: .default, handler: { action in
                okAction?()
            })
            alertController.addAction(okAction)
            
            if !cancelPreferred {
                alertController.preferredAction = okAction
            }
        }
        
        if hasCancel {
            let cancelAction = UIAlertAction(title: cancelTitle ?? (hasOk ? localizedString("Cancel") : localizedString("OK")), style: hasOk ? .cancel : .default, handler: { action in
                cancelAction?()
            })
            alertController.addAction(cancelAction)
            
            if cancelPreferred {
                alertController.preferredAction = cancelAction
            }
        }
        
        if alertController.actions.count == 1 && alertController.preferredAction == nil {
            alertController.preferredAction = alertController.actions.first
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    public func present(errorMessage: String) {
        var host: UIViewController = self
        if let modalController = host.presentedViewController {
            host = modalController
        }
        
        host.present(alertWithTitle: localizedString("Error"), message: errorMessage)
    }
    
    public func present(error: Error) {
        present(errorMessage: error.localizedDescription)
    }
    
    @objc
    private func showActivityIfNeeded() {
        UIView.animate(withDuration: 0.2) {
            self.activityHUD.alpha = 1
        }
    }
}
