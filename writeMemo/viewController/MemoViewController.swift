//
//  MemoViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController,DrawOptionViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,AlertViewDelegate, InputTextViewDelegate, ImageAlertViewDelegate {
    
    var inputViewTag:Int = 0
    
    @IBOutlet weak var underView: UIView!
    
    //タッチ操作時に使用する変数
    var touchBeganPoint:CGPoint!
    var movePoint:CGPoint!
    
    //メモ用のビュー
    @IBOutlet weak var garbageView: UIView!
    @IBOutlet weak var drawImageView: UIImageView!
    @IBOutlet weak var inputImageView: UIImageView!
    
    //テキスト用の変数
    let inputTextView:InputTextView = InputTextView.instanceInputTextView()
    var tempTextViewCenter:CGPoint!
    
    //ペイント用の変数
    var paintViewIsAppeared:Bool = false
    var drawOptionView:DrawOptionView = DrawOptionView.instance()
    var penThickness:Int = 0 //ペンの細さ
    var penColor:UIColor! //ペンの色
    var isDrawMode:Bool = true //鉛筆モードか消しゴムモードか
    var isDrawViewTouchEnabled:Bool = false //ペイントビューをタップできるか
    
    //イメージ用の変数
    var imageAlertView:ImageAlertView = ImageAlertView.instanceImageAlertView()
    
    enum InputType: Int {
        case InputTypeText = 0
        case InputTypeEditText
        case InputTypePaint
        case InputTypeImage
        case InputTypeMove
        case InputTypeDelete
    }
    
    var alertView:AlertView = AlertView.instanceView() //アラートのビュー
    
    var inputType:InputType = InputType.InputTypeMove //初期inputTypeはmoveにしておく
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeDraw()
    }
    
    // MARK: - touchInteraction
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch: AnyObject in touches {
            let t:UITouch = touch as! UITouch
            if(isDrawViewTouchEnabled){
                touchBeganPoint = t.locationInView(drawImageView)
                //println("drawImageViewのタッチした座標:\(touchBeganPoint)")
            } else {
                touchBeganPoint = t.locationInView(inputImageView)
                //println("inputImageViewのタッチした座標:\(touchBeganPoint)")
            }
            
            if(inputType == InputType.InputTypeText){
                //テキスト入力のビューを開く&テキストを新規作成
                self.openInputTextView()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        if(isDrawViewTouchEnabled){
            movePoint = touch.locationInView(drawImageView) //drawImageViewの移動した先の座標を取得
            //println("drawImageViewの移動先の座標:\(movePoint)")
        } else {
            movePoint = touch.locationInView(inputImageView) //inputImageViewの移動した先の座標を取得
            //println("inputImageViewの移動先の座標:\(movePoint)")
        }
        
        if(inputType == InputType.InputTypePaint){
            //ペイント操作
            self.drawPaint()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    }
    
    // MARK: - UIGestureRecognizer
    func moveView(sender:UIPanGestureRecognizer){
        
        if(inputType == InputType.InputTypeMove){
            
            if (sender.state == .Began) {
                self.appearGarbageView() //削除用のビューを表示
            }
            
            //ドラッグしたビューを移動
            let translation:CGPoint = sender.translationInView(self.view)
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
            sender.setTranslation(CGPointZero, inView: self.view)
            
            //移動しているときは影をつける
            sender.view!.layer.masksToBounds = false
            sender.view!.layer.shadowOffset = CGSizeMake(-7, 7) //左下に影をつける
            sender.view!.layer.shadowRadius = 5
            sender.view!.layer.shadowOpacity = 0.6
            
            print("タグ：\(sender.view?.tag)をつけたビューを移動してます")
            
            if(sender.state == .Ended){
                sender.view!.layer.shadowOpacity = 0.0 //ドラッグ終了したら影を非表示
                
                if(CGRectIntersectsRect(self.garbageView.frame, sender.view!.frame)){
                    //削除用のビューに重なっていたらアラートを表示
                    alertView.delegate = self
                    alertView.pinView = sender.view
                    alertView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                    alertView.showAlertView()
                    self.view.addSubview(alertView)
                } else {
                    //削除用のビューに重ならなかったら
                    self.disappearGarbageView() //削除用のビューを非表示
                }
            }
        }
    }
    
    func pinchView(sender:UIPinchGestureRecognizer){
        
        if(inputType == InputType.InputTypeMove){
            //ビューを拡大縮小
            self.view.bringSubviewToFront(sender.view!)
            sender.view!.transform = CGAffineTransformScale(sender.view!.transform,sender.scale, sender.scale)
            sender.scale = 1.0
        }
    }
    
    func rotateView(sender:UIRotationGestureRecognizer){
        
        if(inputType == InputType.InputTypeMove){
            //ビューを回転
            self.view.bringSubviewToFront(sender.view!)
            sender.view!.transform = CGAffineTransformRotate(sender.view!.transform, sender.rotation)
            sender.rotation = 0
        }
    }
    
    //UIGestureRecognizerを複数受け付けるデリゲート
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - garbageView
    func appearGarbageView(){
        UIView.animateWithDuration(
            0.1,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                self.underView.center = CGPointMake(self.view.frame.width/2, self.underView.center.y + self.underView.frame.height)
            }, completion: nil
        )
    }
    func disappearGarbageView(){
        UIView.animateWithDuration(
            0.1,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                self.underView.center = CGPointMake(self.view.frame.width/2, self.underView.center.y - self.underView.frame.height)
            }, completion: nil
        )
    }
    
    // MARK: - AlertViewDelegate
    func tapYes(view: UIView) {
        print("ドラッグしたビューを削除")
        view.removeFromSuperview()
        alertView.closeAlertView()
    }
    func tapNo(view:UIView) {
        print("削除しない")
        alertView.closeAlertView()
        
        UIView.animateWithDuration(0.1) { () -> Void in
            //ドラッグしたビューをメモのビューの方に戻す
            view.center = CGPointMake(view.center.x, self.inputImageView.frame.size.height * 0.75)
        }
    }
    func removeAlertView() {
        alertView.removeFromSuperview()
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
        //inputType = InputType.InputTypeImage
        
        self.changeFromDraw()
        self.openImageAlertView()
    }
    
    @IBAction func changeInputMove(sender: AnyObject) {
        //移動モードにチェンジ
        inputType = InputType.InputTypeMove
        self.changeFromDraw()
    }
    
    @IBAction func changeInputDelete(sender: AnyObject) {
        //削除モードにチェンジ
        inputType = InputType.InputTypeDelete
        self.changeFromDraw()
    }
    
    // MARK: - Text
    func openInputTextView(){
        //テキストビューが配置されてないところをタップしたときはテキストビューを新規生成
        inputTextView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        inputTextView.showInputTextView()
        inputTextView.inputTextViewDelegate = self
        tempTextViewCenter = touchBeganPoint
        self.view.addSubview(inputTextView)
    }
    
    func tapView(sender:UITapGestureRecognizer){
        //配置したテキストビューをタップしたときは再編集
        let selectedTextView:UITextView = sender.view as! UITextView
        inputTextView.showEditInputTextView(selectedTextView)
        inputTextView.inputTextViewDelegate = self
        tempTextViewCenter = touchBeganPoint
        self.view.addSubview(inputTextView)
    }
    
    // MARK: - InputTextVewDelegate
    func createTextView(text: String, color: UIColor, fontSize: Float) {
        //タップした箇所に新しくテキストビューを生成する
        self.inputTextView.removeFromSuperview()
        self.addTextView(text, color: color, fontSize: fontSize)
    }
    func editTextView(text: String, color: UIColor, fontSize: Float, textView: UITextView) {
        //テキストビューを変更
        self.inputTextView.removeFromSuperview()
        textView.removeFromSuperview()
        self.addTextView(text, color: color, fontSize: fontSize)
    }

    func addTextView(text: String, color: UIColor, fontSize: Float){
        let textView:UITextView = UITextView(frame: CGRectMake(0, 0, 0, 0))
        textView.editable = false
        textView.selectable = false
        textView.scrollEnabled = false
        textView.textAlignment = .Center
        textView.text = text
        textView.textColor = color
        textView.font = UIFont(name: "KAWAIITEGAKIMOJI", size: CGFloat(fontSize))
        textView.backgroundColor = UIColor(red:0.06, green:0.22, blue:0.49, alpha:1.0)
        textView.sizeToFit()
        
        //サイズを調整
        if (textView.frame.width > inputImageView.frame.width){
            textView.frame = CGRectMake(0, 0, inputImageView.frame.width - 20 , textView.frame.height)
        } else if (textView.frame.height > inputImageView.frame.height){
            textView.frame = CGRectMake(0, 0, textView.frame.width, inputImageView.frame.height - 20)
        } else if (textView.frame.width > inputImageView.frame.width && textView.frame.height > inputImageView.frame.height){
            textView.frame = CGRectMake(0, 0, inputImageView.frame.width - 20, inputImageView.frame.height - 20)
        }
        textView.clipsToBounds = true
        textView.center = tempTextViewCenter
        
        //UIGestureを登録(タップ、移動、回転)
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapView:")
        let moveGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
        let rotateGesture:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
        textView.addGestureRecognizer(tapGesture)
        textView.addGestureRecognizer(moveGesture)
        textView.addGestureRecognizer(rotateGesture)
        
        if textView.text != "" {
            inputImageView.addSubview(textView)
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
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Round) // 線の角を丸くする
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(penThickness)); // 線の太さを指定
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), penColor.CGColor) //線の色を指定(UIColorで)
        
        if(!isDrawMode){
            //消しゴムモードのときはブレンドモードをClearにする(これで描画した線を消すことができる)
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Clear)
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
    func setThickness(thickness thickness: Int) {
        print("現在の太さ：\(thickness)")
        penThickness = thickness
    }
    func setColor(color color: UIColor) {
        print("受け渡した色：\(color)")
        penColor = color
    }
    func changeEditMode(isPaint isPaint: Bool) {
        print("鉛筆モード？:\(isPaint)")
        isDrawMode = isPaint
    }
    
    // MARK: - Image
    func openImageAlertView(){
        imageAlertView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        imageAlertView.showImageAlertView()
        imageAlertView.delegate = self
        self.view.addSubview(imageAlertView)
    }
    
    func shotPicture(){
        //写真を撮る
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        if(UIImagePickerController.isSourceTypeAvailable(sourceType)){
            //インスタンス作成(カメラ機能を作成)
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            
            //カメラの画面をmodal表示
            self.presentViewController(cameraPicker, animated: true, completion: nil)
        }
    }
    func openLibraryPicture(){
        //カメラロール
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            
            let cameraPicker = UIImagePickerController()
            
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            
            self.presentViewController(cameraPicker, animated: true, completion: nil)
        }
    }
    func closeImageAlertView(){
        //imageAlertViewを閉じる
        imageAlertView.removeFromSuperview()
    }
    
    //撮影が完了した際に呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.closeImageAlertView()
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //イメージビューとそれの土台となるビューを作成
            //TODO:画像のビューをaddSubViewする際はテキストのビューよりも背面にする
            let baseView:UIView = UIView()
            baseView.frame = CGRectMake(inputImageView.frame.size.width/2 - 110, inputImageView.frame.size.height/2 - 110, 210, 210)
            baseView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            baseView.layer.borderWidth = 1.5
            inputImageView.addSubview(baseView)
            
            let imageView = UIImageView()
            imageView.frame = CGRectMake(5, 5, 200, 200)
            imageView.image = pickedImage
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            baseView.addSubview(imageView)
            
            //UIGestureを登録(移動、拡大縮小、回転)
            let movePan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
            let pinchPan:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchView:")
            let rotatePan:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
            baseView.addGestureRecognizer(movePan)
            baseView.addGestureRecognizer(pinchPan)
            baseView.addGestureRecognizer(rotatePan)
            
            if(picker.sourceType == .Camera){
                //カメラで撮影した写真は端末に保存する
                 UIImageWriteToSavedPhotosAlbum(pickedImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            //エラーメッセージを表示するメソッド
            print(error.code)
        }
    }

}
