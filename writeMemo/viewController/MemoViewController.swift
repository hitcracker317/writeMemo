//
//  MemoViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController,UITextViewDelegate {
    
    enum InputType: Int {
        case InputTypeText = 0
        case InputTypePaint
        case InputTypeImage
        case InputTypeMove
        case InputTypeDelete
    }
    
    var inputType:InputType = InputType.InputTypeMove //初期inputTypeはmoveにしておく
    
    @IBOutlet weak var memoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tapMemoView(sender: AnyObject) {
        println(sender)
        
        var point = sender.locationOfTouch(0, inView: memoView)
        println("タッチした座標:\(point)")
        
        
        
        
        
        
        
        
        var textView:UITextView = UITextView(frame: CGRectMake(point.x - 12, point.y - 12, 24, 24))
        textView.text = ""
        textView.delegate = self
        textView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.00, alpha:1.0)
        memoView.addSubview(textView)
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func changeInputText(sender: AnyObject) {
        //テキスト編集モードにチェンジ
        inputType = InputType.InputTypeText
    }
    
    // MARK: - TextViewDelegate
    func textViewDidChange(textView: UITextView) {
        //文字が入力された際、文字量に応じてTextViewのRect値を変更
        var textRect:CGRect = textView.frame;
        textRect.size.width = textView.contentSize.width
        textRect.size.height = textView.contentSize.height
        textView.frame = textRect;
    }
    
}
