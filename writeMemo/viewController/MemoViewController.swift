//
//  MemoViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController,DrawOptionViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    var inputViewTag:Int = 0
    
    @IBOutlet weak var underView: UIView!
    
    //タッチ操作時に使用する変数
    var touchBeganPoint:CGPoint!
    var movePoint:CGPoint!
    
    //メモ用のビュー
    @IBOutlet weak var drawImageView: UIImageView!
    @IBOutlet weak var inputImageView: UIImageView!
    
    //テキスト用の変数
    var drawTextViewWidth:CGFloat!
    var drawTextViewHeight:CGFloat!
    
    //ペイント用の変数
    var paintViewIsAppeared:Bool = false
    var drawOptionView:DrawOptionView = DrawOptionView.instance()
    var penThickness:Int = 0 //ペンの細さ
    var penColor:UIColor! //ペンの色
    var isDrawMode:Bool = true //鉛筆モードか消しゴムモードか
    var isDrawViewTouchEnabled:Bool = false //ペイントビューをタップできるか
    
    //イメージ用の変数
    var imageAlertView:UIView = UIView()
    var imageAlertBackView:UIView = UIView()
    var imageAlertViewIsAppeared:Bool = false
    
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
                //println("drawImageViewのタッチした座標:\(touchBeganPoint)")
            } else {
                touchBeganPoint = t.locationInView(inputImageView)
                //println("inputImageViewのタッチした座標:\(touchBeganPoint)")
            }
        }
        
        if(imageAlertViewIsAppeared){
            self.closeImageAlertView()
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        if(isDrawViewTouchEnabled){
            movePoint = touch.locationInView(drawImageView) //drawImageViewの移動した先の座標を取得
            //println("drawImageViewの移動先の座標:\(movePoint)")
        } else {
            movePoint = touch.locationInView(inputImageView) //inputImageViewの移動した先の座標を取得
            //println("inputImageViewの移動先の座標:\(movePoint)")
        }
        
        if(inputType == InputType.InputTypeText){
            //ドラッグした範囲にUITextViewを生成する
            self.drawTextView()
        }
        
        if(inputType == InputType.InputTypePaint){
            //ペイント操作
            self.drawPaint()
        }
        
        /*
        if(inputType == InputType.InputTypeMove){
            //配置したオブジェクトの移動
            //テキスト生成やオブジェクトをドラッグするときに使用する
            let location = touch.locationInView(inputImageView) //ドラッグ後の座標を取得
            let prevLocation = touch.previousLocationInView(inputImageView) //ドラッグ前の座標を取得
            
            //ドラッグをして移動したx,y距離をとる
            let movePosX:CGFloat = location.x - prevLocation.x
            let movePosY:CGFloat = location.y - prevLocation.y
            
            println("移動した距離(x:\(movePosX),y:\(movePosY)")
        }*/
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        if(inputType == InputType.InputTypeText){
            //テキストを入力
            if(drawTextViewWidth >= 20){
                self.inputText()
            }
            inputImageView.image = nil //矩形を削除
            
        } else if (inputType == InputType.InputTypeEditText){
            //テキスト入力中のときはキーボードを閉じる
            self.view.endEditing(true);
            inputType = InputType.InputTypeText
        }
    }
    
    // MARK: - UIGestureRecognizer
    //TODO:moveモードのときのみ移動できるようにする
    //TODO:移動するビューがメモのビューよりも外に出ないようにする
    func moveView(sender:UIPanGestureRecognizer){
        //ドラッグしたビューを移動
        var translation:CGPoint = sender.translationInView(self.view)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPointZero, inView: self.view)
        
        println("テキストの\(sender.view?.tag)タグをつけたビューを移動してます")
    }
    
    func pinchView(sender:UIPinchGestureRecognizer){
        //ビューを拡大縮小
        self.view.bringSubviewToFront(sender.view!)
        sender.view!.transform = CGAffineTransformScale(sender.view!.transform,sender.scale, sender.scale)
        sender.scale = 1.0
    }
    
    func rotateView(sender:UIRotationGestureRecognizer){
        //ビューを回転
        self.view.bringSubviewToFront(sender.view!)
        sender.view!.transform = CGAffineTransformRotate(sender.view!.transform, sender.rotation)
        sender.rotation = 0
    }
    
    //UIGestureRecognizerを複数受け付けるデリゲート
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - changeInputType
    @IBAction func changeInputText(sender: AnyObject) {
        self.changeFromDraw()
        
        //テキスト追加モードにチェンジ
        inputType = InputType.InputTypeText
        self.toggleEditableTextView()
    }
    
    @IBAction func changeInputPaint(sender: AnyObject) {
        //ペイント追加モードにチェンジ
        inputType = InputType.InputTypePaint
        self.toggleEditableTextView()
        
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
        //inputType = InputType.InputTypeImage
        
        self.changeFromDraw()
        //self.toggleEditableTextView()
        
        self.openImageAlertView()
    }
    
    @IBAction func changeInputMove(sender: AnyObject) {
        //移動モードにチェンジ
        //TODO:このモードに切り替えたら配置した文字、画像を移動・拡大縮小・移動できるようにする
        inputType = InputType.InputTypeMove
        
        self.changeFromDraw()
        self.toggleEditableTextView()
    }
    
    @IBAction func changeInputDelete(sender: AnyObject) {
        //削除モードにチェンジ
        inputType = InputType.InputTypeDelete
        
        self.changeFromDraw()
        self.toggleEditableTextView()
    }
    
    // MARK: - Text
    func drawTextView(){
        //ドラッグ操作中、テキストビューの領域の矩形を描く
        //TODO:x軸のマイナス方向にドラッグした際も対応
        UIGraphicsBeginImageContext(inputImageView.frame.size)
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor(red:0.06, green:0.22, blue:0.49, alpha:0.3).CGColor) //矩形の描画色
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
        textView.font = UIFont(name: "KAWAIITEGAKIMOJI", size: 20)
        inputViewTag++
        textView.tag = inputViewTag //生成するtextViewにタグをつける(ひとつひとつのテキストビューを特定するため)
        textView.delegate = self
        textView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.00, alpha:0.0)
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor(red:0.06, green:0.22, blue:0.49, alpha:1.0).CGColor
        
        //UIGestureを登録(移動、拡大縮小、回転)
        var movePan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
        var pinchPan:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchView:")
        var rotatePan:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
        textView.addGestureRecognizer(movePan)
        textView.addGestureRecognizer(pinchPan)
        textView.addGestureRecognizer(rotatePan)
        
        inputImageView.addSubview(textView) 
        
        textView.becomeFirstResponder()
        
        inputType = InputType.InputTypeEditText
    }
    
    func toggleEditableTextView(){
        for view in inputImageView.subviews{
            if let textView = view as? UITextView {
                //UITextViewを継承しているビューのみを取得
                if(inputType == InputType.InputTypeText){
                    //テキストモードだったら編集可能
                    textView.editable = true
                } else {
                    //それ以外のモードだったら編集無効
                    textView.editable = false
                }
            }
        }
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
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        //TODO:テキストを入力する領域がキーボードに覆われる場合、画面全体をスクロール
        textView.layer.borderWidth = 2
        inputType = InputType.InputTypeEditText
        return true
    }
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        //入力したテキストの行数に応じてテキストビューのサイズを可変
        var textRect:CGRect = textView.frame;
        textRect.size.height = textView.contentSize.height
        textView.frame = textRect
        
        //テキスト入力矩形値(横縦)の初期化
        drawTextViewWidth = 0
        drawTextViewHeight = 0
        textView.layer.borderWidth = 0
        
        return true
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
    
    // MARK: - Image
    func openImageAlertView(){
        let appearImageAlertViewHeight:CGFloat = 110
        let marginWidth:CGFloat = 0
        let marginHeight:CGFloat = 0
        let buttonHeight:CGFloat = 55
        
        //カメラかライブラリかで写真のアップロード方法を選択するボタンを生成
        imageAlertView.frame = CGRectMake(0, self.view.frame.size.height , self.view.frame.size.width, appearImageAlertViewHeight + 30)
        imageAlertView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        self.view.addSubview(imageAlertView)
        
        //全体を覆う半透明なview
        imageAlertBackView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        imageAlertBackView.backgroundColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:0.3)
        self.view.insertSubview(imageAlertBackView, belowSubview: imageAlertView)
        
        imageAlertViewIsAppeared = true
        
        var shootPictureButton:UIButton = UIButton()
        shootPictureButton.frame = CGRectMake(marginWidth, marginHeight, self.view.frame.size.width - (marginWidth * 2), buttonHeight)
        shootPictureButton.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        shootPictureButton.setTitle("カメラを撮影", forState: .Normal)
        shootPictureButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        shootPictureButton.addTarget(self, action: "tapShootPictureButton", forControlEvents: .TouchUpInside)
        imageAlertView.addSubview(shootPictureButton)
        
        var libralyPictureButton:UIButton = UIButton()
        libralyPictureButton.frame = CGRectMake(marginWidth,buttonHeight + (marginHeight * 2), self.view.frame.size.width - (marginWidth * 2), buttonHeight)
        libralyPictureButton.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        libralyPictureButton.setTitle("カメラロール", forState: .Normal)
        libralyPictureButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        libralyPictureButton.addTarget(self, action: "tapLibraryPictureButton", forControlEvents: .TouchUpInside)
        imageAlertView.addSubview(libralyPictureButton)
        
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.3,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() -> Void  in
                // アニメーションする処理
                self.imageAlertView.frame.origin.y = self.view.frame.size.height - appearImageAlertViewHeight
            },
            completion:nil
        )
    }
    
    func closeImageAlertView(){
        //imageAlertViewが表示されているときは閉じる
        imageAlertBackView.removeFromSuperview()
        
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.3,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() -> Void  in
                self.imageAlertView.frame.origin.y = self.view.frame.size.height
            },
            completion:{(Bool finished) -> Void in
                self.imageAlertView.removeFromSuperview()
                self.imageAlertViewIsAppeared = false
        })
    }
    
    func tapShootPictureButton(){
        //写真を撮る
        println("写真を撮る")
        
        //使用しているデバイスでカメラが使用可能かどうか確かめる
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        if(UIImagePickerController.isSourceTypeAvailable(sourceType)){
            //インスタンス作成(カメラ機能を作成)
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            
            //カメラの画面をmodal表示
            self.presentViewController(cameraPicker, animated: true, completion: nil)
            
        } else {
            println("エラー")
        }
    }
    
    func tapLibraryPictureButton(){
        //カメラロール
        
        //カメラロールのURLを取得
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            
            let cameraPicker = UIImagePickerController()
            
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            
            self.presentViewController(cameraPicker, animated: true, completion: nil)
        } else {
            println("エラー")
        }

    }
    
    //撮影が完了した際に呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        self.closeImageAlertView()
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //イメージビューとそれの土台となるビューを作成
            //TODO:画像のビューをaddSubViewする際はテキストのビューよりも背面にする
            var baseView:UIView = UIView()
            baseView.frame = CGRectMake(inputImageView.frame.size.width/2 - 110, inputImageView.frame.size.height/2 - 110, 220, 220)
            baseView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            baseView.layer.borderWidth = 1.5
            inputImageView.addSubview(baseView)
            
            var imageView = UIImageView()
            imageView.frame = CGRectMake(10, 10, 200, 200)
            imageView.image = pickedImage
            baseView.addSubview(imageView)
            
            inputViewTag++
            baseView.tag = inputViewTag
            var pan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
            
            //UIGestureを登録(移動、拡大縮小、回転)
            var movePan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
            var pinchPan:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchView:")
            var rotatePan:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
            baseView.addGestureRecognizer(movePan)
            baseView.addGestureRecognizer(pinchPan)
            baseView.addGestureRecognizer(rotatePan)
        }
        
        //assetURL(デバイスの中の写真が保存されている場所の情報)を取得
        let assetURL:AnyObject = info[UIImagePickerControllerReferenceURL]!
        //conbert phrase to NSURL
        let url = NSURL(string: assetURL.description)
        println("画像のurl = \(url)")
        
        //カメラ画面orカメラロール画面を閉じる処理
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}
