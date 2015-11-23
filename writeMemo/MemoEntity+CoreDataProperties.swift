//
//  MemoEntity+CoreDataProperties.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/23.
//  Copyright © 2015年 A.M. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MemoEntity {

    @NSManaged var mamoTitle: String?
    @NSManaged var memoDrawing: NSData?
    @NSManaged var memoThumbnail: NSData?
    @NSManaged var memoViews: NSData?
    @NSManaged var saveDate: NSDate?
    @NSManaged var tagNumber: NSNumber?

}
