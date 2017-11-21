import Foundation
import CoreData

extension MemoEntity {

    @NSManaged var memoTitle: String?
    @NSManaged var memoDrawing: NSData?
    @NSManaged var memoThumbnail: NSData?
    @NSManaged var memoViews: NSData?
    @NSManaged var saveDate: NSDate?
    @NSManaged var memoID: NSNumber?
    @NSManaged var viewTagNumber: NSNumber?

}
