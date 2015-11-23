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
    
    
    func createEntity(title:NSString){
        //データモデルを新規に作成
        
        if let managedObjectContext = appdelegate.managedObjectContext{
        
            //新しくデータを作成するためのEntityを作成
            let managedObject:AnyObject = NSEntityDescription.insertNewObjectForEntityForName("MemoEntity", inManagedObjectContext: managedObjectContext)
        
            //メモのタイトル、作成した日付
            let memoEntity = managedObject as! MemoEntity
            memoEntity.memoTitle = title as String
            memoEntity.saveDate = NSDate()
            
            print("タイトル：\(title)")
        
            appdelegate.saveContext() //データの保存処理(これ忘れないでね！)
        }
    }
    
}
