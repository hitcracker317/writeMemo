//
//  InputTextView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/16.
//  Copyright © 2015年 A.M. All rights reserved.
//

import UIKit

class InputTextView: UIView ,UITextViewDelegate{

    @IBOutlet weak var backInputTextView: UIView!
    @IBOutlet weak var scrollInputTextView: UIScrollView!
    @IBOutlet weak var inputTextView: UITextView!
    
    class func instanceInputTextView() -> InputTextView {
        return UINib(nibName: "InputTextView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! InputTextView
    }
    
    func showInputTextView(){
        self.backInputTextView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.5)
        inputTextView.becomeFirstResponder()
        
        self.prepareKeyBoard()
    }
    
    func prepareKeyBoard(){
        //キーボードに色とフォントサイズを変更するボタンを設置
        
        //ボタンを配置するビューをキーボードに追加する
        let keyBoardView:UIView = UIView(frame: CGRectMake(0,0,self.frame.width,50))
        keyBoardView.backgroundColor = UIColor.lightGrayColor()
        inputTextView.delegate = self
        inputTextView.inputAccessoryView = keyBoardView
        
        //カラーを変更するボタンを設置
        let changeColorButton:UIButton = UIButton()
        changeColorButton.frame = CGRectMake(10, 3, 44, 44)
        changeColorButton.backgroundColor = UIColor(red:0.98, green:0.87, blue:0.94, alpha:1)
        changeColorButton.setTitle("カ", forState: .Normal)
        changeColorButton.addTarget(self, action:"changeEditColor:", forControlEvents: .TouchUpInside)
        keyBoardView.addSubview(changeColorButton)
        //フォントサイズを変更するボタンを設置
        let changeFontSizeButton:UIButton = UIButton()
        changeFontSizeButton.frame = CGRectMake(20 + changeColorButton.frame.width, 3, 44, 44)
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
        
        //
        
    }
    
    func changeEditColor(sender:UIButton){
        print("カラー")
    }
    func changeEditFontSize(sender:UIButton){
        print("フォントサイズ")
    }
    
    func finishEditText(sender:UIButton){
        print("テキストの編集を終了")
        //キーボードを閉じる
        //このビューを閉じる
        //memoViewControllerに入力したテキストの値を受け渡す
    }
    
}
