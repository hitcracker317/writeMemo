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
    
    //アラート
    var alertView:AlertView = AlertView.instanceView()
    
    //テキスト用の変数
    let inputTextView:InputTextView = InputTextView.instanceInputTextView()
    var tempTextViewCenter:CGPoint!
    var inputType:InputType = InputType.InputTypeMove //初期inputTypeはmoveにしておく
    
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
    
    //CoreData
    var memoEntity:MemoEntity!
    var selectedMemoID:Int = 0 //選択したメモのID
    var totalViewTag:Int = 0 //ビューのタグのトータル値
    var viewsDictionary:NSMutableDictionary = NSMutableDictionary() //配置したビューを格納する配列
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeDraw()
        
        //memoEntity = MemoCRUD.sharedInstance.readMemoEntity(memoID: selectedMemoID) //選択したメモのエンティティを取得する
        //print("メモのタイトル:\(memoEntity.memoTitle)")
        
        //self.navigationItem.title = memoEntity.memoTitle
        //self.totalViewTag = Int(memoEntity.viewTagNumber!) //viewのタグ数

        /*
        if (memoEntity.memoViews != nil){
            //memoEntity.memoViewsがnilだとクラッシュするのでnilじゃなときのみ処理を入れる
            viewsDictionary = NSKeyedUnarchiver.unarchiveObject(with: memoEntity.memoViews! as Data)! as! NSMutableDictionary //画面に生成したviewを格納するdictionary
            
            //TODO:すべてのビューを列挙
            for(key,someViews) in viewsDictionary {
                let someView:UIView = someViews as! UIView
                inputImageView.addSubview(someView)
                
                //TODO:画像のボーダーが保持されていないかもしれない
                //TODO:画像が逆さま
                
                //TODO:keyの値をチェック!!!
                if((key as AnyObject).contains("テキスト")){
                    //テキストビューのとき
                    //TODO:テキストのタップ、移動、回転が消えている
                    let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapView:")
                    let moveGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
                    let rotateGesture:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
                    someView.addGestureRecognizer(tapGesture)
                    someView.addGestureRecognizer(moveGesture)
                    someView.addGestureRecognizer(rotateGesture)
                }

                if((key as AnyObject).contains("イメージ")){
                    //画像のとき
                    //TODO:画像の移動、回転、拡大が消えている
                    
                }
            }
        }
        
        if(drawImageView.image == nil){
            //drawImageViewの初期化
            drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        if(memoEntity.memoDrawing != nil){
            drawImageView.image = UIImage(data: memoEntity.memoDrawing! as Data)
        }
        */
        
    }
    
    // MARK: - touchInteraction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: AnyObject in touches {
            let t:UITouch = touch as! UITouch
            if(isDrawViewTouchEnabled){
                touchBeganPoint = t.location(in: drawImageView)
            } else {
                touchBeganPoint = t.location(in: inputImageView)
            }
            
            if(inputType == InputType.InputTypeText){
                //テキスト入力のビューを開く&テキストを新規作成
                self.openInputTextView()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as UITouch!
        if(isDrawViewTouchEnabled){
            movePoint = touch?.location(in: drawImageView) //drawImageViewの移動した先の座標を取得
        } else {
            movePoint = touch?.location(in: inputImageView) //inputImageViewの移動した先の座標を取得
        }
        
        if(inputType == InputType.InputTypePaint){
            //ペイント操作
            self.drawPaint()
        }
    }
    
    // MARK: - UIGestureRecognizer
    func moveView(sender:UIPanGestureRecognizer){
        
        if(inputType == InputType.InputTypeMove){
            
            if (sender.state == .began) {
                self.appearGarbageView() //削除用のビューを表示
            }
            
            //ドラッグしたビューを移動
            let translation:CGPoint = sender.translation(in: self.view)
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
            sender.setTranslation(CGPoint.zero , in: self.view)
            
            //移動しているときは影をつける
            sender.view!.layer.masksToBounds = false
            sender.view!.layer.shadowOffset = CGSize(width: -7, height: 7) //左下に影をつける
            sender.view!.layer.shadowRadius = 5
            sender.view!.layer.shadowOpacity = 0.6
            
            if(sender.state == .ended){
                sender.view!.layer.shadowOpacity = 0.0 //ドラッグ終了したら影を非表示
                
                if(self.garbageView.frame.intersects(sender.view!.frame)){
                    //削除用のビューに重なっていたらアラートを表示
                    alertView.delegate = self
                    alertView.pinView = sender.view!
                    alertView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
                    alertView.showAlertView()
                    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.addSubview(alertView)
                } else {
                    //削除用のビューに重ならなかったら
                    self.disappearGarbageView() //削除用のビューを非表示
                    
                    //TODO:セーブ
                }
            }
        }
    }
    
    func pinchView(sender:UIPinchGestureRecognizer){
        
        if(inputType == InputType.InputTypeMove){
            //ビューを拡大縮小
            self.view.bringSubview(toFront: sender.view!)
            //sender.view!.transform = CGAffineTransformScale(sender.view!.transform,sender.scale, sender.scale)
            //sender.view!.transform.scaledBy(x: sender.view!, y: sender.view!)
            sender.scale = 1.0
        }
    }
    
    func rotateView(sender:UIRotationGestureRecognizer){
        
        if(inputType == InputType.InputTypeMove){
            //ビューを回転
            self.view.bringSubview(toFront: sender.view!)
            //sender.view!.transform = CGAffineTransformRotate(sender.view!.transform, sender.rotation)
            sender.view!.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
    
    //UIGestureRecognizerを複数受け付けるデリゲート
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - garbageView
    func appearGarbageView(){
        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: { () -> Void in
                self.underView.center = CGPoint(x:self.view.frame.width/2, y:self.underView.center.y + self.underView.frame.height)
            }, completion: nil
        )
    }
    func disappearGarbageView(){
        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: { () -> Void in
                self.underView.center = CGPoint(x:self.view.frame.width/2, y:self.underView.center.y - self.underView.frame.height)
            }, completion: nil
        )
    }
    
    // MARK: - delegateAlertViewDelegate
    func tapYes(view: UIView) {
        print("ドラッグしたビューを削除")
        
        //viewをdictionaryから削除
        let viewTagkey:NSString = "タグ\(view.tag)" as NSString
        view.removeFromSuperview()
        viewsDictionary.removeObject(forKey: viewTagkey)
        
        //TODO:削除したdictionaryを保存
        
        alertView.closeAlertView()
        self.disappearGarbageView()
    }
    func tapNo(view:UIView) {
        print("削除しない")
        alertView.closeAlertView()
        self.disappearGarbageView()
        
        UIView.animate(withDuration: 0.1) { () -> Void in
            //ドラッグしたビューをメモのビューの方に戻す
            view.center = CGPoint(x:view.center.x, y:self.inputImageView.frame.size.height * 0.75)
        }
    }
    func removeAlertView() {
        alertView.removeFromSuperview()
    }
    
    // MARK: - changeTextMode
    @IBAction func changeTextMode(_ sender: Any) {
        //テキスト入力モードにチェンジ
        self.changeFromDraw()
        inputType = InputType.InputTypeText
    }

    @IBAction func changeInpautPaint(sender: AnyObject) {
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
        inputTextView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        inputTextView.showInputTextView()
        inputTextView.inputTextViewDelegate = self
        tempTextViewCenter = touchBeganPoint
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(inputTextView)
    }
    
    func tapView(sender:UITapGestureRecognizer){
        //配置したテキストビューをタップしたときは再編集
        let selectedTextView:UITextView = sender.view as! UITextView
        inputTextView.editSliderValue = (selectedTextView.font?.pointSize)! //タップしたラベルのフォントサイズを受け渡す。
        inputTextView.showEditInputTextView(textView: selectedTextView)
        inputTextView.inputTextViewDelegate = self
        tempTextViewCenter = sender.view?.center
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(inputTextView)
    }
    
    // MARK: - InputTextVewDelegate
    func createTextView(text: String, color: UIColor, fontSize: Float) {
        //タップした箇所に新規にテキストビューを生成する
        self.inputTextView.removeFromSuperview()
        self.addTextView(text: text, color: color, fontSize: fontSize, isNewTextView: true, textViewTag: 0)
    }
    func editTextView(text: String, color: UIColor, fontSize: Float, textView: UITextView) {
        //テキストビューを編集
        self.inputTextView.removeFromSuperview()
        self.addTextView(text: text, color: color, fontSize: fontSize, isNewTextView: false,textViewTag: textView.tag)
        textView.removeFromSuperview()
    }

    func addTextView(text: String, color: UIColor, fontSize: Float, isNewTextView:Bool, textViewTag:Int){
        let textView:UITextView = UITextView(frame: CGRect(x:0, y:0, width:0, height:0))
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.textAlignment = .center
        textView.text = text
        textView.textColor = color
        textView.font = UIFont(name: "HiraginoSans-W3", size: CGFloat(fontSize))
        textView.backgroundColor = UIColor(red:0.06, green:0.22, blue:0.49, alpha:0.0)
        textView.sizeToFit()
        
        //サイズを調整
        if (textView.frame.width > inputImageView.frame.width){
            textView.frame = CGRect(x:0, y:0, width:inputImageView.frame.width - 20, height:textView.frame.height)
        } else if (textView.frame.height > inputImageView.frame.height){
            textView.frame = CGRect(x:0, y:0, width:textView.frame.width, height:inputImageView.frame.height - 20)
        } else if (textView.frame.width > inputImageView.frame.width && textView.frame.height > inputImageView.frame.height){
            textView.frame = CGRect(x:0, y:0, width:inputImageView.frame.width, height:inputImageView.frame.height - 20)
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
            //文字列が空のときにはテキストを生成しない
            
            if(isNewTextView){
                //新規にviewを生成する場合はタグをカウントアップしてviewを生成
                totalViewTag+=1
                textView.tag = totalViewTag
            } else {
                //編集した場合は編集前のタグを保持しておいて、そちらを再度生成するビューのタグにセット
                textView.tag = textViewTag
            }
            
            let viewTagKey:NSString = "テキストタグ\(textView.tag)" as NSString
            viewsDictionary[viewTagKey] = textView //dictionaryにビューを追加 or 中身を差し替え
            
            //TODO:メモの内容を保存(タグのトータル値も)
            MemoCRUD.sharedInstance.saveEntity(memoID: selectedMemoID, memoViews: viewsDictionary, viewTagNumber: totalViewTag, memoDrawingImageView: drawImageView, memoThumbnailImageView: drawImageView)
            
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
        
        drawImageView.image?.draw(in: CGRect(x:0, y:0, width:drawImageView.frame.width, height:drawImageView.frame.size.height)) //memoViewにセットされている画像（UIImageを描画)
        UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round) // 線の角を丸くする
        UIGraphicsGetCurrentContext()!.setLineWidth(CGFloat(penThickness)); // 線の太さを指定
        UIGraphicsGetCurrentContext()!.setStrokeColor(penColor.cgColor) //線の色を指定(UIColorで)
        
        if(!isDrawMode){
            //消しゴムモードのときはブレンドモードをClearにする(これで描画した線を消すことができる)
            UIGraphicsGetCurrentContext()!.setBlendMode(CGBlendMode.clear)
        }

        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.move(to: CGPoint(x:touchBeganPoint.x, y:touchBeganPoint.y)) // 線の描画開始座標をセット
        context.addLine(to: CGPoint(x:movePoint.x ,y:movePoint.y)) // 線の描画終了座標をセット
        context.strokePath() // 描画の開始～終了座標まで線を引く
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext() // 描画領域を画像（UIImage）としてmemoViewにセット
        
        UIGraphicsEndImageContext() // 描画領域のクリア
        
        touchBeganPoint = movePoint; // 現在のタッチ座標を次の開始座標にセット
    }
    
    func openDrawView(){
        drawOptionView.frame = CGRect(x:0, y:self.view.frame.size.height , width:self.view.frame.size.width, height:170)
        drawOptionView.backgroundColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:0.5)
        drawOptionView.delegate = self
        self.view.insertSubview(drawOptionView, belowSubview: underView)
        
        self.paintViewIsAppeared = true
        
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.3,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {() -> Void  in
                // アニメーションする処理
                self.drawOptionView.frame.origin.y = self.view.frame.size.height - 135 - 44
            },
            completion:nil
        )
    }
    
    func closeDrawView(){
        self.paintViewIsAppeared = false
        
        UIView.animate(withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.3,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {() -> Void  in
                // アニメーションする処理
                self.drawOptionView.frame.origin.y = self.view.frame.size.height
            },
            completion:{(finished) -> Void in
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
            drawImageView.isUserInteractionEnabled = true
        } else {
            //drawViewのタッチを受け付けない
            drawImageView.isUserInteractionEnabled = false
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
        imageAlertView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        imageAlertView.showImageAlertView()
        imageAlertView.delegate = self
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(imageAlertView)
    }
    
    func shotPicture(){
        //写真を撮る
        self.closeImageAlertView()
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
        if(UIImagePickerController.isSourceTypeAvailable(sourceType)){
            //インスタンス作成(カメラ機能を作成)
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            
            //カメラの画面をmodal表示
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    func openLibraryPicture(){
        //カメラロール
        self.closeImageAlertView()
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            
            let cameraPicker = UIImagePickerController()
            
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    func closeImageAlertView(){
        //imageAlertViewを閉じる
        imageAlertView.removeFromSuperview()
    }
    
    //撮影が完了した際に呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //イメージビューとそれの土台となるビューを作成
            //TODO:画像のビューをaddSubViewする際はテキストのビューよりも背面にする
            let baseView:UIView = UIView()
            baseView.frame = CGRect(x:inputImageView.frame.size.width/2 - 110, y:inputImageView.frame.size.height/2 - 110, width:210, height:210)
            baseView.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            baseView.layer.borderWidth = 1.5
            
            //UIGestureを登録(移動、拡大縮小、回転)
            let movePan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "moveView:")
            let pinchPan:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchView:")
            let rotatePan:UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotateView:")
            baseView.addGestureRecognizer(movePan)
            baseView.addGestureRecognizer(pinchPan)
            baseView.addGestureRecognizer(rotatePan)

            inputImageView.addSubview(baseView)
            
            let imageView:UIImageView = UIImageView()
            imageView.frame = CGRect(x:5, y:5, width:200, height:200)
            imageView.image = pickedImage
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            baseView.addSubview(imageView)
            
            //ビューにタグを付与してdictionary
            totalViewTag+=1
            baseView.tag = totalViewTag
            let viewTagKey = "イメージタグ\(baseView.tag)"
            viewsDictionary[viewTagKey] = baseView
            
            //TODO:セーブ(タグのトータル値も)
            MemoCRUD.sharedInstance.saveEntity(memoID: selectedMemoID, memoViews: viewsDictionary, viewTagNumber: totalViewTag, memoDrawingImageView: drawImageView, memoThumbnailImageView: drawImageView)
            
            if(picker.sourceType == .camera){
                //カメラで撮影した写真は端末に保存する
                 UIImageWriteToSavedPhotosAlbum(pickedImage, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            //エラーメッセージを表示するメソッド
            print(error.code)
        }
    }

}
