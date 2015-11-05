//
//  MemoViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController,UITextViewDelegate {
    
    //TODO:テキストビューの個数をカウントする変数を用意(テキストビューにタグをつけるため)
    var textTag:Int = 0
    
    enum InputType: Int {
        case InputTypeText = 0
        case InputTypeEditText
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
        
        if(inputType == InputType.InputTypeText){
            //テキスト入力
            
            var point = sender.locationOfTouch(0, inView: memoView)
            println("タッチした座標:\(point)")
            
            var textView:UITextView = UITextView(frame: CGRectMake(point.x - 60, point.y - 12, 120, 24))
            textView.text = ""
            textTag++
            textView.tag = textTag //生成するtextViewにタグをつける(ひとつひとつのテキストビューを特定するため)
            textView.delegate = self
            textView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.00, alpha:1.0)
            memoView.addSubview(textView)
            
            textView.becomeFirstResponder()
            
            inputType = InputType.InputTypeEditText

        } else if (inputType == InputType.InputTypeEditText){
            //テキスト入力中のときはキーボードを閉じる
            self.view.endEditing(true);
            inputType = InputType.InputTypeText
        }
    }
    
    @IBAction func changeInputText(sender: AnyObject) {
        //テキスト編集モードにチェンジ
        inputType = InputType.InputTypeText
    }
    
    // MARK: - TextViewDelegate
    func textViewDidChange(textView: UITextView) {
        //入力したテキストの行数に応じてテキストビューのサイズを可変
        var textRect:CGRect = textView.frame;
        textRect.size.height = textView.contentSize.height
        textView.frame = textRect;
    }
    
}
