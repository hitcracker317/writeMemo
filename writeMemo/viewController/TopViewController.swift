//
//  TopViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class TopViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate{

    @IBOutlet weak var memoCollectionView: UICollectionView!
    
    @IBOutlet weak var topNavigationbar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib:UINib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.registerNib(nib, forCellWithReuseIdentifier: "Cell")
        
        //self.topNavigationbar.frame = CGRectMake(0, 0, 100, 66)
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = memoCollectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MemoCollectionViewCell
        cell.memoTitle.text = "メモ\(indexPath.row)"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("\(indexPath.row)を選択！")
    }
    
    @IBAction func open(sender: AnyObject) {
        var backgroundviewController = BackgroundViewController()
        var memoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MemoViewController") as! UIViewController
        
        backgroundviewController.goNextViewController(fromViewController:self, toViewController: memoViewController)
        
    }
    
}

