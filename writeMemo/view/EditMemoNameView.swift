//
//  EditMemoNameView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/22.
//  Copyright © 2015年 A.M. All rights reserved.
//

import UIKit

protocol EditMemoNameViewDelegate:class{
    func tapOK(title:NSString)
    func tapCancel()
    func removeEditMemoTitleView()
}

class EditMemoNameView: UIView ,UITextFieldDelegate{

    weak var delegate:EditMemoNameViewDelegate! = nil
    
    @IBOutlet weak var titleTextView: UITextField!
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var backAlertView: UIView!
    
    @IBOutlet weak var pleaseInputLabel: UILabel!
    
    class func instanceView() -> EditMemoNameView {
        return UINib(nibName: "EditMemoNameView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! EditMemoNameView
    }
    
    func showAlertView(){
        self.titleTextView.delegate = self
        self.pleaseInputLabel.hidden = true
        self.alertView.alpha = 1.0
        self.backAlertView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.5)
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
                        self.delegate.removeEditMemoTitleView()
                        self.titleTextView.text = ""
                })
        })
    }

    @IBAction func tapOK(sender: AnyObject) {
        //タイトルが空だったら警告文を出して先には進めないようにする
        if(titleTextView.text == ""){
            pleaseInputLabel.hidden = false
        } else {
            self.delegate.tapOK(self.titleTextView.text!)
        }
        
    }
    
    @IBAction func tapCancel(sender: AnyObject) {
        self.delegate.tapCancel()
    }
    
    //MARK: - UITextField
    func textFieldDidBeginEditing(textField: UITextField) {
        pleaseInputLabel.hidden = true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleTextView.resignFirstResponder();
        return true;
    }
}
