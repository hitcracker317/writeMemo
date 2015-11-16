//
//  AlertView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/15.
//  Copyright © 2015年 A.M. All rights reserved.
//

import UIKit

protocol AlertViewDelegate:class{
    func tapYes(view:UIView)
    func tapNo(view:UIView)
    func removeAlertView()
}

class AlertView: UIView {
    
    weak var delegate:AlertViewDelegate! = nil
    
    var pinView:UIView!
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    
    
    class func instanceView() -> AlertView {
        return UINib(nibName: "AlertView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! AlertView
    }
    
    func showAlertView(){
        self.alertView.alpha = 1.0
        self.alertView.transform = CGAffineTransformMakeScale(0.8, 0.8)
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.alertView.transform = CGAffineTransformMakeScale(1.2, 1.2)
        }, completion: {(BOOL) -> Void in
            UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }, completion: nil)
        })
    }
    
    func closeAlertView(){
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.alertView.transform = CGAffineTransformMakeScale(1.2, 1.2)
        }, completion: {(BOOL) -> Void in
            UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.alertView.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }, completion: {(BOOL) -> Void in
                self.delegate.removeAlertView()
            })
        })
    }
    
    @IBAction func tapYes(sender: AnyObject) {
        self.delegate.tapYes(pinView)
    }
    
    @IBAction func tapNo(sender: AnyObject) {
        self.delegate.tapNo(pinView)
    }
    
}
