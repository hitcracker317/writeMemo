//
//  ColorPaletteScrollView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/17.
//  Copyright © 2015年 A.M. All rights reserved.
//

import UIKit

protocol ColorPalletViewDelegate:class{
    func setColor(color:UIColor) //色
}

class ColorPaletteView: UIScrollView {

    weak var colorPalletDelgate:ColorPalletViewDelegate! = nil
    
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
    
    override func drawdraw(_ rect: CGRect) {
        super.draw(rect)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        //スクロールビューのスクロールサイズ
        let palletWidth:CGFloat = 44
        let palletHeight:CGFloat = 44
        let palletMargin:CGFloat = 3
        self.contentSize = CGSizeMake((palletWidth + palletMargin) * CGFloat(colorArray.count) + palletMargin , 50)
        
        for(var i = 0; i < colorArray.count; i++){
            //カラーパレットボタンを生成
            var xPosition:CGFloat = 3.0
            let yPosition:CGFloat = 3.0
            
            if i == 0 {
                xPosition = 3
            } else if i >= 1 {
                xPosition = ((palletWidth + palletMargin) * CGFloat(i)) + palletMargin
            }
            
            //ボタン
            let colorButton:UIButton = UIButton()
            colorButton.frame = CGRectMake(xPosition, yPosition, palletWidth, palletHeight)
            colorButton.backgroundColor = colorArray[i]
            colorButton.tag = i
            colorButton.addTarget(self, action:"changeColor:", for:.touchUpInside)
            self.addSubview(colorButton)
        }
        
        self.contentOffset = CGPointMake(0, 0) //スクロールの初期位置

    }
        
    func changeColor(sender:UIButton){
        //鉛筆の色を変更
        //self.changeDrawMode(sender) //消しゴムモードの場合は鉛筆モードに変更
        self.colorPalletDelgate.setColor(color: sender.backgroundColor!)
    }

    
}
