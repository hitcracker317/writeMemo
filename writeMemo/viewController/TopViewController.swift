//
//  TopViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func open(sender: AnyObject) {
        var backgroundviewController = BackgroundViewController()
        var memoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MemoViewController") as! UIViewController
        
        backgroundviewController.goNextViewController(fromViewController:self, toViewController: memoViewController)
        
    }
    
}

