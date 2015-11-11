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
    
    @IBOutlet weak var underView: UIView!
    
    //タッチ操作時に使用する変数
    var touchBeganPoint:CGPoint!
    var movePoint:CGPoint!
    
    //メモ用のビュー
    @IBOutlet weak var drawImageView: UIImageView!
    @IBOutlet weak var inputImageView: UIImageView!
    
    //テキスト用の変数
    var currentTextView:UITextView! //現在、エディットしているテキストビューを格納
    var drawTextViewWidth:CGFloat!
    var drawTextViewHeight:CGFloat!
    
    //ペイント用の変数
    var paintViewIsAppeared:Bool = false
    var drawOptionView:DrawOptionView = DrawOptionView.instance()
    var penThickness:Int = 0 //ペンの細さ
    var penColor:UIColor! //ペンの色
    var isDrawMode:Bool = true //鉛筆モードか消しゴムモードか
    var isDrawViewTouchEnabled:Bool = false //ペイントビューをタップできるか
    
    enum InputType: Int {
        case InputTypeText = 0
        case InputTypeEditText
        case InputTypePaint
        case InputTypeImage
        case InputTypeMove
        case InputTypeDelete
    }
    
    var inputType:InputType = InputType.InputTypeMove //初期inputTypeはmoveにしておく
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeDraw()
        
    }
    
    // MARK: - touchInteraction
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        for touch: AnyObject in touches {
            var t:UITouch = touch as! UITouch
            if(isDrawViewTouchEnabled){
                touchBeganPoint = t.locationInView(drawImageView)
                println("drawImageViewのタッチした座標:\(touchBeganPoint)")
            } else {
                touchBeganPoint = t.locationInView(inputImageView)
                println("inputImageViewのタッチした座標:\(touchBeganPoint)")
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        if(isDrawViewTouchEnabled){
            movePoint = touch.locationInView(drawImageView) //drawImageViewの移動した先の座標を取得
            println("drawImageViewの移動先の座標:\(movePoint)")
        } else {
            movePoint = touch.locationInView(inputImageView) //inputImageViewの移動した先の座標を取得
            println("inputImageViewの移動先の座標:\(movePoint)")
        }
        
        
        if(inputType == InputType.InputTypeText){
            //ドラッグした範囲にUITextViewを生成する
            self.drawTextView()
        }
        
        if(inputType == InputType.InputTypePaint){
            //ペイント操作
            self.drawPaint()
        }
        
        //テキスト生成やオブジェクトをドラッグするときに使用する
        /*
        let location = aTouch.locationInView(memoView) //移動した先の座標を取得
        let prevLocation = aTouch.previousLocationInView(memoView) //移動する前の座標を取得
        
        //ドラッグ操作をして移動したx,y距離をとる
        let movePosX:CGFloat = location.x - prevLocation.x
        let movePosY:CGFloat = location.y - prevLocation.y
        
        //self.memoDelegate.memoTouchMove(deltaX: movePosX, deltaY: movePosY)
        println("移動した距離(x:\(movePosX),y:\(movePosY)")
        */
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        if(inputType == InputType.InputTypeText){
            //テキストを入力
            if(drawTextViewWidth >= 20){
                self.inputText()
            }
        } else if (inputType == InputType.InputTypeEditText){
            //テキスト入力中のときはキーボードを閉じる
            self.view.endEditing(true);
            inputType = InputType.InputTypeText
            
            //入力したテキストの行数に応じてテキストビューのサイズを可変
            var textRect:CGRect = currentTextView.frame;
            textRect.size.height = currentTextView.contentSize.height
            currentTextView.frame = textRect
            
            //テキスト入力矩形値(横縦)の初期化
            drawTextViewWidth = 0
            drawTextViewHeight = 0
            currentTextView.layer.borderWidth = 0
            currentTextView = nil
        }
    }
    
    // MARK: - changeInputType
    @IBAction func changeInputText(sender: AnyObject) {
        self.changeFromDraw()
        
        //テキスト追加モードにチェンジ
        inputType = InputType.InputTypeText
    }
    
    @IBAction func changeInputPaint(sender: AnyObject) {
        //ペイント追加モードにチェンジ
        inputType = InputType.InputTypePaint
        
        isDrawViewTouchEnabled = true
        self.changeDrawViewTouchEnabled()
        
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
    
    // MARK: - Text
    func drawTextView(){
        //ドラッグ操作中、テキストビューの領域の矩形を描く
        UIGraphicsBeginImageContext(inputImageView.frame.size)
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor(red:0.06, green:0.22, blue:0.49, alpha:0.5).CGColor) //矩形の描画色
        drawTextViewWidth = movePoint.x - touchBeganPoint.x
        drawTextViewHeight = movePoint.y - touchBeganPoint.y
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(touchBeganPoint.x, touchBeganPoint.y, drawTextViewWidth, drawTextViewHeight));
        inputImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func inputText(){
        //テキスト入力
        var textView:UITextView = UITextView(frame: CGRectMake(touchBeganPoint.x, touchBeganPoint.y, drawTextViewWidth, drawTextViewHeight))
        textView.text = ""
        textTag++
        textView.tag = textTag //生成するtextViewにタグをつける(ひとつひとつのテキストビューを特定するため)
        textView.delegate = self
        textView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.00, alpha:0.0)
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor(red:0.06, green:0.22, blue:0.49, alpha:1.0).CGColor
        currentTextView = textView
        inputImageView.addSubview(textView)
        
        textView.becomeFirstResponder()
        
        inputType = InputType.InputTypeEditText
    }
    
    // MARK: - TextViewDelegate
    func textViewDidChange(textView: UITextView) {
        //入力したテキストの行数に応じてテキストビューのサイズを可変
        var textRect:CGRect = textView.frame;
        textRect.size.height = textView.contentSize.height
        
        if(textView.contentSize.height >= drawTextViewHeight){
            textView.frame = textRect
        }
    }
    
    // MARK: - Draw
    func initializeDraw(){
        penThickness = 7
        penColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
    }
    
    func drawPaint(){
        //CoreGraphicsを利用してドラッグした軌跡を描画
        
        UIGraphicsBeginImageContext(drawImageView.frame.size) // 描画領域をmemoView(UIImageView)の大きさで生成
        
        drawImageView.image?.drawInRect(CGRectMake(0, 0, drawImageView.frame.width, drawImageView.frame.size.height)) //memoViewにセットされている画像（UIImageを描画)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound) // 線の角を丸くする
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(penThickness)); // 線の太さを指定
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), penColor.CGColor) //線の色を指定(UIColorで)
        
        if(!isDrawMode){
            //消しゴムモードのときはブレンドモードをClearにする(これで描画した線を消すことができる)
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear)
        }
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchBeganPoint.x, touchBeganPoint.y); // 線の描画開始座標をセット
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), movePoint.x, movePoint.y); // 線の描画終了座標をセット
        CGContextStrokePath(UIGraphicsGetCurrentContext()) // 描画の開始～終了座標まで線を引く
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext() // 描画領域を画像（UIImage）としてmemoViewにセット
        
        UIGraphicsEndImageContext() // 描画領域のクリア
        
        touchBeganPoint = movePoint; // 現在のタッチ座標を次の開始座標にセット
    }
    
    func openDrawView(){
        drawOptionView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, 170)
        drawOptionView.backgroundColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:0.5)
        drawOptionView.delegate = self
        self.view.insertSubview(drawOptionView, belowSubview: underView)
        
        self.paintViewIsAppeared = true
        
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.3,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() -> Void  in
                // アニメーションする処理
                self.drawOptionView.frame.origin.y = self.view.frame.size.height - 135 - 44
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
                self.drawOptionView.frame.origin.y = self.view.frame.size.height
            },
            completion:{(Bool finished) -> Void in
                self.drawOptionView.removeFromSuperview()
            }
        )
    }
    
    func changeFromDraw(){
        //ペイントモードから他のモードに切り替えたときに呼ばれるメソッド
        self.closeDrawView()
        isDrawViewTouchEnabled = false
        self.changeDrawViewTouchEnabled()
    }
    
    func changeDrawViewTouchEnabled(){
        if(isDrawViewTouchEnabled){
            //drawViewのタッチを受け付ける
            drawImageView.userInteractionEnabled = true
        } else {
            //drawViewのタッチを受け付けない
            drawImageView.userInteractionEnabled = false
        }
    }
    
    // MARK: - DrawOptionViewDelegate
    func setThickness(#thickness: Int) {
        println("現在の太さ：\(thickness)")
        penThickness = thickness
    }
    func setColor(#color: UIColor) {
        println("受け渡した色：\(color)")
        penColor = color
    }
    func changeEditMode(#isPaint: Bool) {
        println("鉛筆モード？:\(isPaint)")
        isDrawMode = isPaint
    }
}
