//
//  DrawOptionView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/05.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class DrawOptionView: UIView {

    /// 移譲先
    weak var delegate: CustomViewDelegate! = nil
    
    @IBOutlet weak var palletIconImage: UIImageView!
    @IBOutlet weak var thickIconImage: UIImageView!
    @IBOutlet weak var thinIconImage: UIImageView!
    
    @IBOutlet weak var palletScrollView: UIScrollView!

    class func instance() -> DrawOptionView {
        return UINib(nibName: "DrawOptionView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! DrawOptionView
    }
    
    required init(coder aDecoder: NSCoder) {
        //xibやstoryboardにviewを配置した時に呼ばれる
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    func setUp(){
        //ビューのセットアップのメソッド
        
    }
    
    override func awakeFromNib() {
        // XIB読み込みんだ際に呼ばれるメソッド
        
        //スクロールビューのスクロールサイズ
        var palletWidth:CGFloat = 44
        var palletHeight:CGFloat = 44
        var palletMargin:CGFloat = 3
        palletScrollView.contentSize = CGSizeMake(((palletWidth + palletMargin) * 12) + palletMargin , 50)
        
        for i in 0...11 {
            //カラーパレットボタンを生成
            var xPosition:CGFloat = 3.0
            var yPosition:CGFloat = 3.0
            
            if i == 0 {
                xPosition = 3
            } else if i >= 1 {
                xPosition = ((palletWidth + palletMargin) * CGFloat(i)) + palletMargin
            }
            
            // Scrollviewに追加
            var colorButton:UIButton = UIButton()
            colorButton.frame = CGRectMake(xPosition, yPosition, palletWidth, palletHeight)
            if(i % 2 == 0){
                colorButton.backgroundColor = UIColor.blackColor()
            } else {
                colorButton.backgroundColor = UIColor.blueColor()
            }
            
            colorButton.tag = i
            colorButton.addTarget(self, action: "changeColor:", forControlEvents:.TouchUpInside)
            palletScrollView.addSubview(colorButton)
        }
        
        palletScrollView.contentOffset = CGPointMake(0, 0) //スクロールの初期位置
    }
    
    func changeColor(sender:UIButton){
        println("色を変えたよ！")
        
        println(sender.backgroundColor)
    }
    
    @IBAction func pushEraserButton(sender: AnyObject) {
        //消しゴムモードに変更
    }
}


//デリゲートはクラスのみ
protocol CustomViewDelegate: class {

}