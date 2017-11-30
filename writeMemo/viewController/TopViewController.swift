import UIKit
import CoreData
import RealmSwift

class TopViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate,MemoCollectionViewDelegate,AlertViewDelegate,EditMemoNameViewDelegate{

    @IBOutlet weak var memoCollectionView: UICollectionView!
    
    var editMemoNameView:EditMemoNameView = EditMemoNameView.instanceView()
    var deleteAlertView:AlertView = AlertView.instanceView()
    
    var deleteIndexPath:NSIndexPath!
    
    var selectedMemoEntity:MemoEntity! //メモのエンティティ
    var memoArray:NSMutableArray = NSMutableArray() //メモのエンティティを保持する配列
    var totalMemoID:Int = 0
    
    var transitionNewMemo:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib:UINib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        memoCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        let ud:UserDefaults = UserDefaults.standard
        totalMemoID = ud.integer(forKey: "totalMemoID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //初期化
        transitionNewMemo = false

        let realm = try! Realm()
        memoArray = realm.objects(Memo.self)
        memoCollectionView.reloadData()
    }
    
    //MARK: - UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memoArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = memoCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MemoCollectionViewCell



        let memo:Memo = memoArray[indexPath.row] as! Memo

        print("メモの中身：\(memoArray)")
        //let memoEntity:MemoEntity = memoArray[indexPath.row] as! MemoEntity
        cell.memoTitle.text = memo.memoTitle
        cell.delegate = self
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        //メモ画面に遷移
        print("\(indexPath.row)を選択！")
        
        selectedMemoEntity = memoArray[indexPath.row] as! MemoEntity
        performSegue(withIdentifier: "openMemo", sender: nil)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "openMemo"){
            let controller = segue.destination as! MemoViewController
            
            if(transitionNewMemo){
                //新規作成をしたときは現在のtotalMemoIDをmemoViewControllerに受け渡す
                controller.selectedMemoID = totalMemoID
            } else {
                //セルを選択したときはセルのエンティティが持つID値を受け渡す
                controller.selectedMemoID = Int(selectedMemoEntity.memoID!)
            }
        }
    }
    
    // MARK: - EditMemoNameView
    @IBAction func newMemoCreate(_ sender: Any) {
        //新規メモを作成するビューを表示
        editMemoNameView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        editMemoNameView.delegate = self
        editMemoNameView.showAlertView()
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(editMemoNameView)
    }

    func tapOK(title:NSString){
        //入力した名前を元に新規メモを作成
        transitionNewMemo = true
        totalMemoID += 1
        let ud = UserDefaults.standard
        ud.set(totalMemoID, forKey: "totalMemoID")
        ud.synchronize()
        MemoManager.sharedInstance.createMemo(title: title, id: totalMemoID)

        //閉じるアニメーション終了したら画面遷移
        editMemoNameView.closeAlertView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.performSegue(withIdentifier: "openMemo", sender: nil)
        }
    }
    func tapCancel() {
        //削除キャンセル
        editMemoNameView.closeAlertView()
    }
    func removeEditMemoTitleView(){
        editMemoNameView.removeFromSuperview()
    }

    // MARK: - DeleteMemo
    func getIndexPath(event:UIEvent) -> NSIndexPath{
        //カスタムセルに配置したUIButtonのインデックスパスを取得するメソッド
        let touch:UITouch = event.allTouches!.first! as UITouch
        let point:CGPoint = touch.location(in: self.memoCollectionView)
        let indexPath:NSIndexPath = self.memoCollectionView.indexPathForItem(at: point)! as NSIndexPath
        return indexPath
    }
    
    func openDeleteAlert(sender: AnyObject,event: UIEvent) {
        print("削除確認をするアラートビューを表示するよ！")
        
        deleteIndexPath = self.getIndexPath(event: event)
        print("\(deleteIndexPath.row)番目のセルのボタンをタップ")
        
        deleteAlertView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        deleteAlertView.delegate = self
        deleteAlertView.showAlertView()
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
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

