//
//  TopViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class TopViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate,MemoCollectionViewDelegate{

    @IBOutlet weak var memoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib:UINib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.registerNib(nib, forCellWithReuseIdentifier: "Cell")
        
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = memoCollectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MemoCollectionViewCell
        cell.memoTitle.text = "メモ\(indexPath.row)"
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //メモ画面に遷移
        print("\(indexPath.row)を選択！")
        performSegueWithIdentifier("openMemo", sender: nil) 
    }
    
    // MARK: - MemoCollectionVewDelegate
    func openDeleteAlert() {
        print("削除確認をするアラートビューを表示するよ！")
    }
        
}

