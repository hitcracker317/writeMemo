import Foundation
import RealmSwift

class Memo: Object {
    dynamic var memoTitle: String?
    dynamic var memoDrawing: NSData?
    dynamic var memoThumbnail: NSData?
    dynamic var memoViews: NSData?
    dynamic var saveDate: NSDate?
    dynamic var memoID: NSNumber?
    dynamic var viewTagNumber: NSNumber?
}
