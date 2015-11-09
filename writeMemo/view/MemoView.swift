//
//  MemoView.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/09.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

protocol MemoViewDelegate:class{
    func memoTocuBegan(#touchPoint:CGPoint) //タッチした座標
    func memoTouchMove(#deltaX:CGFloat,deltaY:CGFloat) //ドラッグ中に移動した座標を取得
    func memoTocuEnd(#touchPoint:CGPoint) //離したときの座標
}

class MemoView: ACEDrawingView {
    
    weak var memoDelegate:MemoViewDelegate! = nil
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        /*
        for touch: AnyObject in touches {
            var t:UITouch = touch as! UITouch
            let point = t.locationInView(self)
            
            //self.memoDelegate.memoTocuBegan(touchPoint: point)
            println("タッチした座標:\(point)")
        }*/
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        /*
        let aTouch = touches.first as! UITouch
        
        let location = aTouch.locationInView(self) //移動した先の座標を取得
        let prevLocation = aTouch.previousLocationInView(self) //移動する前の座標を取得
        
        //ドラッグ操作をして移動したx,y距離をとる
        let movePosX:CGFloat = location.x - prevLocation.x
        let movePosY:CGFloat = location.y - prevLocation.y
        
        //self.memoDelegate.memoTouchMove(deltaX: movePosX, deltaY: movePosY)
        println("移動した距離(x:\(movePosX),y:\(movePosY)")
        */
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        /*
        super.touchesEnded(touches, withEvent: event)
        
        for touch: AnyObject in touches {
            var t:UITouch = touch as! UITouch
            let point = t.locationInView(self)
            
            //self.memoDelegate.memoTocuEnd(touchPoint: point)
            println("離した座標:\(point)")
        }*/
    }
}
