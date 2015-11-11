//
//  DrawOptionView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/05.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

protocol DrawOptionViewDelegate: class {
    //プロトコル：デリゲートメソッドを定義
    func setThickness(#thickness:Int) //太さ
    func setColor(#color:UIColor) //色
    func changeEditMode(#isPaint:Bool) //ペンか消しゴムか
}

class DrawOptionView: UIView {

    weak var delegate: DrawOptionViewDelegate! = nil
    
    @IBOutlet weak var palletIconImage: UIImageView!
    @IBOutlet weak var thickIconImage: UIImageView!
    @IBOutlet weak var thinIconImage: UIImageView!
    
    @IBOutlet weak var changeDrawModeButton: UIButton!
    @IBOutlet weak var changeEraserModeButton: UIButton!

    var isDrawMode:Bool = true //鉛筆モードか消しゴムモードか
    
    @IBOutlet weak var palletScrollView: UIScrollView!

    var colorArray:[UIColor] = [
                                    UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)/*黒色*/,
                                    UIColor(red:0.95, green:0.32, blue:0.32, alpha:1.0)/*赤*/,
                                    UIColor(red:0.95, green:0.61, blue:0.32, alpha:1.0)/*オレンジ*/,
                                    UIColor(red:0.95, green:0.89, blue:0.32, alpha:1.0)/*黄色*/,
                                    UIColor(red:0.78, green:0.95, blue:0.32, alpha:1.0)/*黄緑*/,
                                    UIColor(red:0.32, green:0.95, blue:0.41, alpha:1.0)/*緑*/,
                                    UIColor(red:0.32, green:0.80, blue:0.95, alpha:1.0)/*水色*/,
                                    UIColor(red:0.32, green:0.48, blue:0.95, alpha:1.0)/*青色*/,
                                    UIColor(red:0.49, green:0.32, blue:0.95, alpha:1.0)/*紫*/,
                                    UIColor(red:0.95, green:0.32, blue:0.69, alpha:1.0)/*ピンク*/,
                                    UIColor(red:0.67, green:0.49, blue:0.23, alpha:1.0)/*茶色*/
                                ]
    
    class func instance() -> DrawOptionView {
        return UINib(nibName: "DrawOptionView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! DrawOptionView
    }
    
    required init(coder aDecoder: NSCoder) {
        //xibやstoryboardにviewを配置した時に呼ばれる
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // XIB読み込みんだ際に呼ばれるメソッド
        
        //スクロールビューのスクロールサイズ
        var palletWidth:CGFloat = 44
        var palletHeight:CGFloat = 44
        var palletMargin:CGFloat = 3
        palletScrollView.contentSize = CGSizeMake((palletWidth + palletMargin) * CGFloat(colorArray.count) + palletMargin , 50)
        
        for(var i = 0; i < colorArray.count; i++){
            //カラーパレットボタンを生成
            var xPosition:CGFloat = 3.0
            var yPosition:CGFloat = 3.0
            
            if i == 0 {
                xPosition = 3
            } else if i >= 1 {
                xPosition = ((palletWidth + palletMargin) * CGFloat(i)) + palletMargin
            }
            
            //ボタン
            var colorButton:UIButton = UIButton()
            colorButton.frame = CGRectMake(xPosition, yPosition, palletWidth, palletHeight)
            colorButton.backgroundColor = colorArray[i]
            colorButton.tag = i
            colorButton.addTarget(self, action: "changeColor:", forControlEvents:.TouchUpInside)
            palletScrollView.addSubview(colorButton)
        }
        
        palletScrollView.contentOffset = CGPointMake(0, 0) //スクロールの初期位置
    }
    
    @IBAction func changeThickness(sender: UISlider) {
        //描画の太さを変更
        self.delegate.setThickness(thickness: Int(sender.value))
    }
    
    func changeColor(sender:UIButton){
        //鉛筆の色を変更
        self.changeDrawMode(sender) //消しゴムモードの場合は鉛筆モードに変更
        self.delegate.setColor(color: sender.backgroundColor!)
    }
    
    @IBAction func changeDrawMode(sender: AnyObject) {
        //鉛筆モードに変更
        if(!isDrawMode){
            //TODO:鉛筆モードを選択していることを明示するカーソル的なものを用意
            //TODO:太さのアイコンを鉛筆のアイコンに変更
            isDrawMode = true
            changeDrawModeButton.backgroundColor = UIColor(red:0.86, green:0.33, blue:0.20, alpha:1.0)
            changeEraserModeButton.backgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
            self.delegate.changeEditMode(isPaint: true)
        }
    }
    
    @IBAction func changeEraserMode(sender: AnyObject) {
        //消しゴムモードに変更
        if(isDrawMode){
            //TODO:消しゴムモードを選択していることを明示するカーソル的なものを用意
            //TODO:太さのアイコンを消しゴムのアイコンに変更
            isDrawMode = false
            changeDrawModeButton.backgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
            changeEraserModeButton.backgroundColor = UIColor(red:0.86, green:0.33, blue:0.20, alpha:1.0)
            self.delegate.changeEditMode(isPaint: false)
        }
    }
}
