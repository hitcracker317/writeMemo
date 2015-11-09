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
    var beforeSelectEraser = false //消しゴムモードを選択していたか
    
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
    
    /*
    @IBAction func tapMemoView(sender: AnyObject) {
        /*
        var point = sender.locationOfTouch(0, inView: memoView)
        println("タッチした座標:\(point)")
        
        if(inputType == InputType.InputTypeText){
           //テキスト入力
            self.inputText(point: point)

        } else if (inputType == InputType.InputTypeEditText){
            //テキスト入力中のときはキーボードを閉じる
            self.view.endEditing(true);
            inputType = InputType.InputTypeText
        }*/
    }*/
    
    // MARK: - changeInputType
    @IBAction func changeInputText(sender: AnyObject) {
        self.changeFromDraw()
        
        //テキスト追加モードにチェンジ
        inputType = InputType.InputTypeText
    }
    
    @IBAction func changeInputPaint(sender: AnyObject) {
        //ペイント追加モードにチェンジ
        inputType = InputType.InputTypePaint
        memoView.lineAlpha = 1
        
        if(beforeSelectEraser){
            memoView.drawTool = ACEDrawingToolTypeEraser
        }
        
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
        self.changeFromDraw()
        
        inputType = InputType.InputTypeImage
    }
    
    @IBAction func changeInputMove(sender: AnyObject) {
        //移動モードにチェンジ
        self.changeFromDraw()
        
        inputType = InputType.InputTypeMove
    }
    
    @IBAction func changeInputDelete(sender: AnyObject) {
        //削除モードにチェンジ
        self.changeFromDraw()
        
        inputType = InputType.InputTypeDelete
    }

        
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        for touch: AnyObject in touches {
        var t:UITouch = touch as! UITouch
        let point = t.locationInView(memoView)
        
        //self.memoDelegate.memoTocuBegan(touchPoint: point)
        println("タッチした座標:\(point)")
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let aTouch = touches.first as! UITouch
        
        let location = aTouch.locationInView(memoView) //移動した先の座標を取得
        let prevLocation = aTouch.previousLocationInView(memoView) //移動する前の座標を取得
        
        //ドラッグ操作をして移動したx,y距離をとる
        let movePosX:CGFloat = location.x - prevLocation.x
        let movePosY:CGFloat = location.y - prevLocation.y
        
        //self.memoDelegate.memoTouchMove(deltaX: movePosX, deltaY: movePosY)
        println("移動した距離(x:\(movePosX),y:\(movePosY)")

    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        super.touchesEnded(touches, withEvent: event)
        
        for touch: AnyObject in touches {
        var t:UITouch = touch as! UITouch
        let point = t.locationInView(memoView)
            
        //self.memoDelegate.memoTocuEnd(touchPoint: point)
        println("離した座標:\(point)")
        }
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
        memoView.lineAlpha = 0
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
    
    func changeFromDraw(){
        //ペイントモードから他のモードに切り替えたときに呼ばれるメソッド
        
        self.closeDrawView()
        memoView.lineAlpha = 0
        
        if(beforeSelectEraser){
            memoView.drawTool = ACEDrawingToolTypePen
        }
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
            beforeSelectEraser = false
        } else {
            println("消しゴムモードに切り替えたよ！")
            memoView.drawTool = ACEDrawingToolTypeEraser
            beforeSelectEraser = true
        }
    }
}
