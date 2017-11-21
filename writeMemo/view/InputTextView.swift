import UIKit

protocol InputTextViewDelegate:class{
    func createTextView(text:String,color:UIColor,fontSize:Float)
    func editTextView(text:String,color:UIColor,fontSize:Float,textView:UITextView)
}

class InputTextView: UIView ,UITextViewDelegate,ColorPalletViewDelegate{

    @IBOutlet weak var backInputTextView: UIView!
    @IBOutlet weak var scrollInputTextView: UIScrollView!
    @IBOutlet weak var inputTextView: UITextView!
    
    weak var inputTextViewDelegate:InputTextViewDelegate! = nil
    
    var isColorPalletAppear:ObjCBool = true
    
    let keyBoardButtonHeight:CGFloat = 50
    
    let textViewMargin:CGFloat = 10.0
    let textViewMarginTop:CGFloat = 25.0
    
    let colorPalletView:ColorPaletteView = ColorPaletteView()
    let fontSizeSlider = UISlider()
     var editSliderValue:CGFloat = 0 //テキストビューを再編集するときのためにスライダーの値を保持
    
    var isCreateNewTextView:ObjCBool = true
    var memoViewControllerTextView:UITextView = UITextView()
    
    class func instanceInputTextView() -> InputTextView {
        return UINib(nibName: "InputTextView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! InputTextView
    }
    
    func showInputTextView(){
        //新しくテキストビューを作成する
        self.isCreateNewTextView = true
        self.backInputTextView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.5)
        
        self.inputTextView.text = ""
        self.inputTextView.textColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
        self.inputTextView.font = UIFont(name: "HiraginoSans-W3", size: 25)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: "showKeyboard:", name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        inputTextView.becomeFirstResponder()
        
        self.prepareKeyBoard()
    }
    
    func showEditInputTextView(textView:UITextView){
        self.prepareKeyBoard()
        
        //テキストビューをアップデート
        self.isCreateNewTextView = false
        self.memoViewControllerTextView = textView
        
        self.backInputTextView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.5)
        
        self.inputTextView.text = textView.text
        self.inputTextView.textColor = textView.textColor
        self.inputTextView.font = textView.font
        
        fontSizeSlider.value = Float(self.editSliderValue)
        fontSizeSlider.minimumTrackTintColor = inputTextView.textColor
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: "showKeyboard:", name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        inputTextView.becomeFirstResponder()
    }
    
    func showKeyboard(notification:NSNotification){
        if let userInfo = notification.userInfo{
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue{
                let keyBoardRect = keyboard.cgRectValue
                
                //キーボードの高さを元にテキストビューのframeを調整
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    self.inputTextView.frame = CGRect(x:self.textViewMargin, y: self.textViewMarginTop, width:self.frame.width - (self.textViewMargin * 2), height:self.frame.height - (self.textViewMarginTop + self.textViewMargin + keyBoardRect.height))
                }, completion: nil)
            }
        }
    }
    
    func prepareKeyBoard(){
        //キーボードにボタンを配置
        //ボタンを配置するビューをキーボードに追加する
        let keyBoardButtonView:UIView = UIView(frame: CGRect(x:0,y:0,width:self.frame.width,height:keyBoardButtonHeight))
        keyBoardButtonView.backgroundColor = UIColor.lightGray
        inputTextView.delegate = self
        inputTextView.inputAccessoryView = keyBoardButtonView
        
        let leftAndRightMargin:CGFloat = 10.0
        let topAndBottonMargin:CGFloat = 3.0
        
        //カラーを変更するボタンを設置
        let changeColorButton:UIButton = UIButton()
        changeColorButton.frame = CGRect(x:leftAndRightMargin, y:topAndBottonMargin, width:44, height:44)
        changeColorButton.backgroundColor = UIColor(red:0.98, green:0.87, blue:0.94, alpha:1)
        changeColorButton.setTitle("カ", for: .normal)
        changeColorButton.addTarget(self, action:"changeEditColor:", for: .touchUpInside)
        keyBoardButtonView.addSubview(changeColorButton)
        //フォントサイズを変更するボタンを設置
        let changeFontSizeButton:UIButton = UIButton()
        changeFontSizeButton.frame = CGRect(x:(leftAndRightMargin * 2) + changeColorButton.frame.width, y:topAndBottonMargin, width:44, height:44)
        changeFontSizeButton.backgroundColor = UIColor(red:0.82, green:0.92, blue:0.97, alpha:1)
        changeFontSizeButton.setTitle("フ", for: .normal)
        changeFontSizeButton.addTarget(self, action:"changeEditFontSize:", for: .touchUpInside)
        keyBoardButtonView.addSubview(changeFontSizeButton)
        
        //キーボードを閉じてテキストの編集を終えるボタン
        let finishButton:UIButton = UIButton()
        finishButton.frame = CGRect(x:self.frame.width - 60, y:0, width:60, height: keyBoardButtonHeight)
        finishButton.backgroundColor = UIColor(red:0.92, green:0.38, blue:0.33, alpha:1)
        finishButton.setTitle("完了", for: .normal)
        finishButton.addTarget(self, action:"finishEditText:", for: .touchUpInside)
        keyBoardButtonView.addSubview(finishButton)
        
        
        let colorAndFontSizeFrame:CGRect = CGRect(x:(leftAndRightMargin * 3) + changeColorButton.frame.width + changeFontSizeButton.frame.width, y:0, width:self.frame.width - ((leftAndRightMargin * 4) + changeColorButton.frame.width + changeFontSizeButton.frame.width + finishButton.frame.width), height:keyBoardButtonHeight)
        
        //カラーパレットのビュー
        colorPalletView.frame = colorAndFontSizeFrame
        colorPalletView.colorPalletDelgate = self
        colorPalletView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        if(isColorPalletAppear).boolValue{
            colorPalletView.isHidden = false
        } else {
            colorPalletView.isHidden = true
        }
        keyBoardButtonView.addSubview(colorPalletView)
        
        //フォントサイズを変更するスライダーを配置
        fontSizeSlider.frame = colorAndFontSizeFrame
        fontSizeSlider.isHidden = true
        fontSizeSlider.minimumValue = 15
        fontSizeSlider.maximumValue = 35
        fontSizeSlider.value = 25
        fontSizeSlider.maximumTrackTintColor = UIColor.gray
        fontSizeSlider.minimumTrackTintColor = inputTextView.textColor
        fontSizeSlider.addTarget(self, action: "changeFontSize:", for: UIControlEvents.valueChanged)
        if(isColorPalletAppear).boolValue{
            fontSizeSlider.isHidden = true
        } else {
            fontSizeSlider.isHidden = false
        }
        keyBoardButtonView.addSubview(fontSizeSlider)
    }
    
    //MARK: - TextColor
    func changeEditColor(sender:UIButton){
        if !isColorPalletAppear.boolValue {
            //TODO:カラーパレットを選択していることを明示
            isColorPalletAppear = true
            colorPalletView.isHidden = false
            fontSizeSlider.isHidden = true
        }
    }
    //MARK: - ColorPalletDelegate
    func setColor(color: UIColor) {
        //文字色を選択した色にする
        self.inputTextView.textColor = color
        fontSizeSlider.minimumTrackTintColor = color
    }
    
    //MARK: - FontSize
    func changeEditFontSize(sender:UIButton){
        if(isColorPalletAppear).boolValue{
            //TODO:フォントサイズを選択していることを明示
            isColorPalletAppear = false
            colorPalletView.isHidden = true
            fontSizeSlider.isHidden = false
        }
    }
    func changeFontSize(sender:UISlider){
        //スライダーの位置に応じてフォントサイズを変更
        inputTextView.font = UIFont(name:"HiraginoSans-W3", size: CGFloat(sender.value))
    }
    
    func finishEditText(sender:UIButton){
        print("テキストの編集を終了")
        //テキストの編集を終了してキーボードを閉じる
        self.endEditing(true);
        self.editSliderValue = CGFloat(self.fontSizeSlider.value)
        
        //閉じる
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseInOut,
            animations: { () -> Void in
                self.inputTextView.frame = CGRect(x:self.textViewMargin, y: self.textViewMarginTop, width:self.frame.width - (self.textViewMargin * 2), height:0)
                }, completion:{ (BOOL) -> Void in
                    //memoViewControllerに入力したテキストの値を受け渡す
                    if self.isCreateNewTextView.boolValue {
                        self.inputTextViewDelegate.createTextView(text: self.inputTextView.text, color: self.inputTextView.textColor!, fontSize: self.fontSizeSlider.value)
                    } else {
                        self.inputTextViewDelegate.editTextView(text: self.inputTextView.text, color: self.inputTextView.textColor!, fontSize: self.fontSizeSlider.value, textView: self.memoViewControllerTextView)
                    }
            }
        )
    }
    
}
