//
//  InputTextView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/16.
//  Copyright © 2015年 A.M. All rights reserved.
//

import UIKit

class InputTextView: UIView ,UITextViewDelegate,ColorPalletViewDelegate{

    @IBOutlet weak var backInputTextView: UIView!
    @IBOutlet weak var scrollInputTextView: UIScrollView!
    @IBOutlet weak var inputTextView: UITextView!
    
    var isColorPalletAppear:ObjCBool = true
    
    let colorPalletView:ColorPaletteView = ColorPaletteView()
    let fontSizeSlider = UISlider()
    
    class func instanceInputTextView() -> InputTextView {
        return UINib(nibName: "InputTextView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! InputTextView
    }
    
    func showInputTextView(){
        self.backInputTextView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.5)
        inputTextView.becomeFirstResponder()
        
        self.prepareKeyBoard()
    }
    
    func prepareKeyBoard(){
        //キーボードにボタンを配置
        
        //ボタンを配置するビューをキーボードに追加する
        let keyBoardView:UIView = UIView(frame: CGRectMake(0,0,self.frame.width,50))
        keyBoardView.backgroundColor = UIColor.lightGrayColor()
        inputTextView.delegate = self
        inputTextView.inputAccessoryView = keyBoardView
        
        let leftAndRightMargin:CGFloat = 10.0
        let topAndBottonMargin:CGFloat = 3.0
        
        //カラーを変更するボタンを設置
        let changeColorButton:UIButton = UIButton()
        changeColorButton.frame = CGRectMake(leftAndRightMargin, topAndBottonMargin, 44, 44)
        changeColorButton.backgroundColor = UIColor(red:0.98, green:0.87, blue:0.94, alpha:1)
        changeColorButton.setTitle("カ", forState: .Normal)
        changeColorButton.addTarget(self, action:"changeEditColor:", forControlEvents: .TouchUpInside)
        keyBoardView.addSubview(changeColorButton)
        //フォントサイズを変更するボタンを設置
        let changeFontSizeButton:UIButton = UIButton()
        changeFontSizeButton.frame = CGRectMake((leftAndRightMargin * 2) + changeColorButton.frame.width, topAndBottonMargin, 44, 44)
        changeFontSizeButton.backgroundColor = UIColor(red:0.82, green:0.92, blue:0.97, alpha:1)
        changeFontSizeButton.setTitle("フ", forState: .Normal)
        changeFontSizeButton.addTarget(self, action:"changeEditFontSize:", forControlEvents: .TouchUpInside)
        keyBoardView.addSubview(changeFontSizeButton)
        
        //キーボードを閉じてテキストの編集を終えるボタン
        let finishButton:UIButton = UIButton()
        finishButton.frame = CGRectMake(self.frame.width - 60, 0, 60, 50)
        finishButton.backgroundColor = UIColor(red:0.92, green:0.38, blue:0.33, alpha:1)
        finishButton.setTitle("完了", forState: .Normal)
        finishButton.addTarget(self, action:"finishEditText:", forControlEvents: .TouchUpInside)
        keyBoardView.addSubview(finishButton)
        
        
        let colorAndFontSizeFrame:CGRect = CGRectMake((leftAndRightMargin * 3) + changeColorButton.frame.width + changeFontSizeButton.frame.width, 0, self.frame.width - ((leftAndRightMargin * 4) + changeColorButton.frame.width + changeFontSizeButton.frame.width + finishButton.frame.width), 50)
        
        //カラーパレットのビュー
        colorPalletView.frame = colorAndFontSizeFrame
        colorPalletView.colorPalletDelgate = self
        colorPalletView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        keyBoardView.addSubview(colorPalletView)
        
        //フォントサイズを変更するスライダーを配置
        fontSizeSlider.frame = colorAndFontSizeFrame
        fontSizeSlider.hidden = true
        fontSizeSlider.minimumValue = 15
        fontSizeSlider.maximumValue = 35
        fontSizeSlider.value = 25
        fontSizeSlider.maximumTrackTintColor = UIColor.grayColor()
        fontSizeSlider.minimumTrackTintColor = inputTextView.textColor
        fontSizeSlider.addTarget(self, action: "changeFontSize:", forControlEvents: UIControlEvents.ValueChanged)
        keyBoardView.addSubview(fontSizeSlider)
    }
    
    //MARK: - TextColor
    func changeEditColor(sender:UIButton){
        if(!isColorPalletAppear){
            print("カラー変更モード")
            //TODO:カラーパレットを選択していることを明示
            isColorPalletAppear = true
            colorPalletView.hidden = false
            fontSizeSlider.hidden = true
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
        if(isColorPalletAppear){
            print("フォントサイズ変更モード")
            //TODO:フォントサイズを選択していることを明示
            isColorPalletAppear = false
            colorPalletView.hidden = true
            fontSizeSlider.hidden = false
        }
    }
    func changeFontSize(sender:UISlider){
        //スライダーの位置に応じてフォントサイズを変更
        inputTextView.font = UIFont(name: "KAWAIITEGAKIMOJI", size: CGFloat(sender.value))
    }
    
    func finishEditText(sender:UIButton){
        print("テキストの編集を終了")
        //キーボードを閉じる
        //このビューを閉じる
        //memoViewControllerに入力したテキストの値を受け渡す
    }
    
}
