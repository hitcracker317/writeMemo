//
//  TopViewController.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/03.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class TopViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate,MemoCollectionViewDelegate,AlertViewDelegate,EditMemoNameViewDelegate{

    @IBOutlet weak var memoCollectionView: UICollectionView!
    
    var editMemoNameView:EditMemoNameView = EditMemoNameView.instanceView()
    var deleteAlertView:AlertView = AlertView.instanceView()
    
    var selectedIndexPath:NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib:UINib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.registerNib(nib, forCellWithReuseIdentifier: "Cell")
    }
    
    //MARK: - UICollectionViewDelegate
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
        
    // MARK: - EditMemoNameView
    @IBAction func openEditMemoNameView(sender: AnyObject) {
        //新規メモを作成するビューを表示
        editMemoNameView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        editMemoNameView.delegate = self
        editMemoNameView.showAlertView()
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.addSubview(editMemoNameView)
    }
    func tapOK(title:NSString){
        //入力した名前を元に新規メモを作成
        
        MemoCRUD.sharedInstance.createEntity(title) //新規にエンティティを作成
        
        editMemoNameView.closeAlertView()
        
        //閉じるアニメーション終了したら画面遷移
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("openMemo", sender: nil)
        }
    }
    func tapCancel() {
        //閉じるだけ
        editMemoNameView.closeAlertView()
    }
    func removeEditMemoTitleView(){
        editMemoNameView.removeFromSuperview()
    }

    // MARK: - DeleteMemo
    func getIndexPath(event:UIEvent) -> NSIndexPath{
        //カスタムセルに配置したUIButtonのインデックスパスを取得するメソッド
        let touch:UITouch = event.allTouches()!.first! as UITouch
        let point:CGPoint = touch.locationInView(self.memoCollectionView)
        let indexPath:NSIndexPath = self.memoCollectionView.indexPathForItemAtPoint(point)!
        return indexPath
    }
    func openDeleteAlert(sender: AnyObject,event: UIEvent) {
        print("削除確認をするアラートビューを表示するよ！")
        
        selectedIndexPath = self.getIndexPath(event)
        print("\(selectedIndexPath.row)番目のセルのボタンをタップ")
        
        deleteAlertView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        deleteAlertView.delegate = self
        deleteAlertView.showAlertView()
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.addSubview(deleteAlertView)
    }
    func tapYes(view: UIView) {
        //セルを削除する
        //TODO:削除したのちはアニメーションを施してセルを整列
        //memoCollectionView.deleteItemsAtIndexPaths([selectedIndexPath])
        //memoCollectionView.reloadData()
        deleteAlertView.closeAlertView()
        
    }
    func tapNo(view: UIView) {
        //削除しない
        deleteAlertView.closeAlertView()
    }
    func removeAlertView() {
        deleteAlertView.removeFromSuperview()
    }
        
}

