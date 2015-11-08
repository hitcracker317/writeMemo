//
//  MemoViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController,DrawOptionViewDelegate,UITextViewDelegate {
    
    var textTag:Int = 0
    var paintViewIsAppeared:Bool = false
    
    var drawView:DrawOptionView = DrawOptionView.instance()
    
    @IBOutlet weak var underView: UIView!
    var isDrawMode:Bool = true //鉛筆モードか消しゴムモードか
    
    enum InputType: Int {
        case InputTypeText = 0
        case InputTypeEditText
        case InputTypePaint
        case InputTypeImage
        case InputTypeMove
        case InputTypeDelete
    }
    
    var inputType:InputType = InputType.InputTypeMove //初期inputTypeはmoveにしておく
    
    @IBOutlet weak var memoView: ACEDrawingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeDraw()
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
        } else if (inputType == InputType.InputTypePaint){
            //TODO：ペイントモードのときのみ描画できるようにする(他のモードのときは描画をしない)
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
    
    // MARK: - Draw
    func initializeDraw(){
        memoView.drawMode = ACEDrawingMode.Scale
        memoView.drawTool = ACEDrawingToolTypePen
        memoView.lineWidth = 7
        memoView.lineColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
    }
    
    func openDrawView(){
        drawView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, 170)
        drawView.backgroundColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:0.5)
        drawView.delegate = self
        self.view.insertSubview(drawView, belowSubview: underView)
        
        self.paintViewIsAppeared = true
        
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.3,
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
        
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.3,
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
    
    // MARK: - DrawOptionViewDelegate
    func setThickness(#thickness: Int) {
        println("現在の太さ：\(thickness)")
        self.memoView.lineWidth = CGFloat(thickness)
    }
    
    func setColor(#color: UIColor) {
        println("受け渡した色：\(color)")
        self.memoView.lineColor = color
    }
    
    func changeEditMode(#isPaint: Bool) {
        isDrawMode = isPaint
        
        if(isDrawMode){
            println("鉛筆モードに切り替えたよ！")
            memoView.drawTool = ACEDrawingToolTypePen
        } else {
            println("消しゴムモードに切り替えたよ！")
            memoView.drawTool = ACEDrawingToolTypeEraser
        }
    }
}
