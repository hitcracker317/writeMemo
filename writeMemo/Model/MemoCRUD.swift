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
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    func readEntitys() -> NSMutableArray{
        //保存した全メモを取得して配列に格納して返す
        
        let memoEntityArray:NSMutableArray = []
        
        if let managedObjectContext = appdelegate.managedObjectContext{
            
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
        
        if let managedObjectContext = appdelegate.managedObjectContext{
            
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
    
    func createEntity(title:NSString,id:Int){
        //データモデルを新規に作成
        
        if let managedObjectContext = appdelegate.managedObjectContext{
        
            //新しくデータを作成するためのEntityを作成
            let managedObject:AnyObject = NSEntityDescription.insertNewObjectForEntityForName("MemoEntity", inManagedObjectContext: managedObjectContext)
        
            //メモのタイトル、作成した日付
            let memoEntity = managedObject as! MemoEntity
            memoEntity.memoTitle = title as String
            memoEntity.memoID = id
            memoEntity.saveDate = NSDate()
            
            appdelegate.saveContext() //データの保存処理(これ忘れないでね！)
        }
    }
    
}
