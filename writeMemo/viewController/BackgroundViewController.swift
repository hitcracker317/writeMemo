//
//  BackgroundViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class BackgroundViewController: UIViewController {
    
    var topViewController:UIViewController! //トップ画面のビューコントローラー
    //var memoViewController:UIViewController! //トップ画面のビューコントローラー
    var childViewController:UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.topViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TopViewController") as! UIViewController
        topViewController.view.frame = self.view.bounds
    
        self.addChildViewController(topViewController) //コンテナビューの子ビューとしてTopViewControllerを追加
        self.view.addSubview(topViewController.view) //表示ビュー(子ビュー)のサブViewとして、TopViewControllerのviewを追加
        topViewController.didMoveToParentViewController(self) //コンテナビューにtopViewControllerの追加の完了を記す
        
        childViewController = topViewController //現在表示しているビューコントローラーを保持
        
    }
    
    func goNextViewController(#fromViewController:UIViewController,toViewController:UIViewController){
        //メモ画面へ遷移
        println("メモ画面へ遷移")
        
        /*
        // 1
        fromViewController.willMoveToParentViewController(nil)
        fromViewController.view.removeFromSuperview()
        fromViewController.removeFromParentViewController()

        
        
        // 2
        addChildViewController(toViewController)

        self.view.addSubview(toViewController.view) //これ入れると落ちる
        
        toViewController.didMoveToParentViewController(self)
        
        childViewController = toViewController
        */
        
        
        
        
        
        toViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController) //遷移先をコンテナビューコントローラーにセット
        
        //新しい画面のビューをaddSubViewすると
        //self.view.addSubview(toViewController.view)
        //toViewController.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height) //遷移先の子ビューコントローラーの初期配置位置
        
        //上2つのソースコードを抜いて、以下のコードを実行すると遷移先と遷移元の子ビューコントローラーは同じ親ビューコントローラーに登録しろ、と警告が出て落ちる
        /*
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.5, options:UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            toViewController.view.frame = fromViewController.view.frame
            fromViewController.view.frame = CGRectMake(-self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)
        }) { (finished) -> Void in
            fromViewController.view.removeFromSuperview()
            fromViewController.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
        }*/

    }
}
