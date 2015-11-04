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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib:UINib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.registerNib(nib, forCellWithReuseIdentifier: "Cell")
        
        
        

        
        //var layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        

        
        var backgroundView = UIView()
        backgroundView.frame = self.memoCollectionView.frame
        backgroundView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.memoCollectionView.backgroundView = backgroundView
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

