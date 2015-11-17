//
//  InputTextView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/16.
//  Copyright © 2015年 A.M. All rights reserved.
//

import UIKit

class InputTextView: UIView {

    @IBOutlet weak var backInputTextView: UIView!
    @IBOutlet weak var scrollInputTextView: UIScrollView!
    @IBOutlet weak var inputTextView: UITextView!
    
    class func instanceInputTextView() -> InputTextView {
        return UINib(nibName: "InputTextView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! InputTextView
    }
    
    func showInputTextView(){
        self.backInputTextView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.5)
        
        inputTextView.becomeFirstResponder()
    }
}
