//
//  MemoCRUD.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/23.
//  Copyright © 2015年 A.M. All rights reserved.
//

import UIKit
import CoreData

class MemoCRUD: NSObject {
    static let sharedInstance = MemoCRUD()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //MARK: - READ
    func readEntitys() -> NSMutableArray{
        //保存した全メモを取得して配列に格納して返す
        
        let memoEntityArray:NSMutableArray = []
        
        if let managedObjectContext = appDelegate.managedObjectContext{
            
            let entity = NSEntityDescription.entityForName("MemoEntity", inManagedObjectContext: managedObjectContext)
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "MemoEntity")
            fetchRequest.entity = entity
            
            
            //フェッチリクエスト(データの検索と取得処理)の実行
            do {
                //取得完了
                let results = try managedObjectContext.executeFetchRequest(fetchRequest)
                
                for managedObject in results {
                    let memoEntity = managedObject as! MemoEntity
                    
                    memoEntityArray.addObject(memoEntity)
                }
            } catch let error as NSError {
                //取得失敗
                print("Fetch failed: \(error.localizedDescription)")
            }
        }
        return memoEntityArray
    }
    
    func readMemoEntity(memoID:Int) -> MemoEntity{
        
        var memoEntity:MemoEntity!
        
        if let managedObjectContext = appDelegate.managedObjectContext{
            
            let entity = NSEntityDescription.entityForName("MemoEntity", inManagedObjectContext: managedObjectContext)
            
            let fetchRequest = NSFetchRequest(entityName:"MemoEntity")
            fetchRequest.entity = entity
            
            //IDを指定することで、対象のデータを取得
            let predicate = NSPredicate(format: "%K = %@","memoID",NSNumber(integer: memoID))
            fetchRequest.predicate = predicate
                
            do {
                //取得完了
                let results = try managedObjectContext.executeFetchRequest(fetchRequest)
                
                for managedObject in results {
                    print(managedObject)
                    memoEntity = managedObject as! MemoEntity
                }
            } catch let error as NSError {
                //取得失敗
                print("Fetch failed: \(error.localizedDescription)")
            }

        }
        return memoEntity
    }
    
    //MARK: - CREATE
    func createEntity(title:NSString,id:Int){
        //データモデルを新規に作成
        
        if let managedObjectContext = appDelegate.managedObjectContext{
        
            //新しくデータを作成するためのEntityを作成
            let managedObject:AnyObject = NSEntityDescription.insertNewObjectForEntityForName("MemoEntity", inManagedObjectContext: managedObjectContext)
        
            //メモのタイトル、作成した日付
            let memoEntity = managedObject as! MemoEntity
            memoEntity.memoTitle = title as String
            memoEntity.memoID = id
            memoEntity.saveDate = NSDate()
            
            appDelegate.saveContext()
        }
    }
    
    //MARK: - UPDATE
    func saveEntity(memoID:Int,memoViews:NSMutableDictionary,viewTagNumber:Int,memoDrawingImageView:UIImageView,memoThumbnailImageView:UIImageView){
        //最後に更新した日時、ビュー、dicitionary、ビューのタグ総数、ペイントした線、メモのスクショを保存
        
        var memoEntity:MemoEntity!
        
        if let managedObjectContext = appDelegate.managedObjectContext{
             let entityDiscription = NSEntityDescription.entityForName("MemoEntity", inManagedObjectContext: managedObjectContext)
            let fetchRequest = NSFetchRequest();
            fetchRequest.entity = entityDiscription;
            let predicate = NSPredicate(format: "%K = %@", "memoID", NSNumber(integer:memoID))
            fetchRequest.predicate = predicate
            
            do {
                //取得完了
                let results = try managedObjectContext.executeFetchRequest(fetchRequest)
                
                for managedObject in results {
                    print(managedObject)
                    memoEntity = managedObject as! MemoEntity
                    
                    memoEntity.saveDate = NSDate() //最後に更新した日時
                    memoEntity.memoViews = NSKeyedArchiver.archivedDataWithRootObject(memoViews) //メモのビュー
                    memoEntity.viewTagNumber = viewTagNumber //ビューのタグの総数
                    
                    if(memoDrawingImageView.image != nil){
                        memoEntity.memoDrawing = UIImagePNGRepresentation(memoDrawingImageView.image!) //ペイントした絵
                    }
                    
                    if(memoThumbnailImageView.image != nil){
                        memoEntity.memoThumbnail = UIImagePNGRepresentation(memoThumbnailImageView.image!) //メモのスクショ
                    }
                }
            } catch let error as NSError {
                //取得失敗
                print("Fetch failed: \(error.localizedDescription)")
            }
            appDelegate.saveContext()
        }
    }
    
}
