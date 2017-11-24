import Foundation
import RealmSwift

class MemoManager: Object {
    static let sharedInstance = MemoManager() //シングルトン
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    //MARK: - READ_LIST
    func readMemoList(){
        //保存した全メモを取得して配列に格納して返す
    }

    //MARK: - READ_CONTENT
    func readMemoCOntent(memoID:Int) {
        //選択したメモの項目のデータを取得
    }

    //MARK: - CREATE
    func createMemo(title:NSString,id:Int){
        //メモのデータモデルを新規に作成
    }

    //MARK: - UPDATE
    func updateMemo(memoID:Int,memoViews:NSMutableDictionary,viewTagNumber:Int,memoDrawingImageView:UIImageView,memoThumbnailImageView:UIImageView){
        //最後に更新した日時、ビュー、dicitionary、ビューのタグ総数、ペイントした線、メモのスクショを保存
    }

    //MARK: - DERETE
    func deleteMemo(memoID:Int) {
        //メモをデータベースから削除
    }
}
