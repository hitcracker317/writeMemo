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
    
    override func drawRect(rect: CGRect) {
        
    }
    
    class func instance() -> DrawOptionView {
        return UINib(nibName: "DrawOptionView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! DrawOptionView
    }
    
    override func awakeFromNib() {
        // XIB読み込み
       
    }
}


//デリゲートはクラスのみ
protocol CustomViewDelegate: class {

}