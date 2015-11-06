//
//  MemoViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController,UITextViewDelegate {
    
    var textTag:Int = 0
    var paintViewIsAppeared:Bool = false
    
    var drawView:DrawOptionView = DrawOptionView.instance()
    
    @IBOutlet weak var underView: UIView!
    
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
        var point = sender.locationOfTouch(0, inView: memoView)
        println("タッチした座標:\(point)")
        
        if(inputType == InputType.InputTypeText){
           //テキスト入力
            self.inputText(point: point)

        } else if (inputType == InputType.InputTypeEditText){
            //テキスト入力中のときはキーボードを閉じる
            self.view.endEditing(true);
            inputType = InputType.InputTypeText
        }
    }
    
    // MARK: - changeInputType
    @IBAction func changeInputText(sender: AnyObject) {
        self.closeDrawView()
        
        //テキスト追加モードにチェンジ
        inputType = InputType.InputTypeText
    }
    
    @IBAction func changeInputPaint(sender: AnyObject) {
        //ペイント追加モードにチェンジ
        inputType = InputType.InputTypePaint
        
        if(paintViewIsAppeared){
            //開いているのなら閉じる
            self.closeDrawView()
        } else {
            //閉じているのなら開く
            self.openDrawView()
        }
    }
    
    @IBAction func changeInputImage(sender: AnyObject) {
        //イメージ追加モードにチェンジ
        self.closeDrawView()
        
        inputType = InputType.InputTypeImage
    }
    
    @IBAction func changeInputMove(sender: AnyObject) {
        //移動モードにチェンジ
        self.closeDrawView()
        
        inputType = InputType.InputTypeMove
    }
    
    @IBAction func changeInputDelete(sender: AnyObject) {
        //削除モードにチェンジ
        self.closeDrawView()
        
        inputType = InputType.InputTypeDelete
    }

    // MARK: - Text
    func inputText(#point:CGPoint){
        //テキスト入力
        var textView:UITextView = UITextView(frame: CGRectMake(point.x - 60, point.y - 12, 120, 24))
        textView.text = ""
        textTag++
        textView.tag = textTag //生成するtextViewにタグをつける(ひとつひとつのテキストビューを特定するため)
        textView.delegate = self
        textView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.00, alpha:1.0)
        memoView.addSubview(textView)
        
        textView.becomeFirstResponder()
        
        inputType = InputType.InputTypeEditText
    }
    
    // MARK: - TextViewDelegate
    func textViewDidChange(textView: UITextView) {
        //入力したテキストの行数に応じてテキストビューのサイズを可変
        var textRect:CGRect = textView.frame;
        textRect.size.height = textView.contentSize.height
        textView.frame = textRect;
    }
    
    // MARK: - Paint
    func openDrawView(){
        drawView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, 170)
        drawView.backgroundColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:0.5)
        self.view.insertSubview(drawView, belowSubview: underView)
        
        self.paintViewIsAppeared = true
        
        UIView.animateWithDuration(0.5, // アニメーションの時間
            delay: 0.0,  // アニメーションの遅延時間
            usingSpringWithDamping: 0.5, // スプリングの効果(0~1で指定する)
            initialSpringVelocity: 0.3,  // バネの初速。(0~1で指定する)
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() -> Void  in
                // アニメーションする処理
                self.drawView.frame.origin.y = self.view.frame.size.height - 135 - 44
            },
            completion:nil
        )
    }
    
    func closeDrawView(){
        self.paintViewIsAppeared = false
        
        UIView.animateWithDuration(0.3, // アニメーションの時間
            delay: 0.0,  // アニメーションの遅延時間
            usingSpringWithDamping: 1.0, // スプリングの効果(0..1)
            initialSpringVelocity: 0.3,  // バネの初速。(0..1)
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() -> Void  in
                // アニメーションする処理
                self.drawView.frame.origin.y = self.view.frame.size.height
            },
            completion:{(Bool finished) -> Void in
                self.drawView.removeFromSuperview()
            }
        )
    }
}
