import UIKit

protocol ImageAlertViewDelegate:class{
    func shotPicture()
    func openLibraryPicture()
    func closeImageAlertView()
}

class ImageAlertView: UIView {

    weak var delegate:ImageAlertViewDelegate! = nil
    
    @IBOutlet weak var alertBackView: UIView!
    @IBOutlet weak var alertView: UIView!
    
    class func instanceImageAlertView() -> ImageAlertView {
        return UINib(nibName: "ImageAlertView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ImageAlertView
    }
    
    override func awakeFromNib() {
        // XIB読み込みんだ際に呼ばれるメソッド
        alertView.center = CGPoint(x:self.frame.width/2, y:self.frame.height + (self.alertView.frame.height/2)) //最初は画面下部に隠す
    }
    
    func showImageAlertView(){
        //カメラアップロードの方法を選択するアクションシートを表示
        alertBackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.3,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {() -> Void  in
                self.alertView.center = CGPoint(x:self.frame.width/2, y:self.frame.height - (self.alertView.frame.height/2))
            },
            completion:nil
        )
    }
    
    @IBAction func openCamera(sender: AnyObject) {
        print("カメラ")
        self.delegate.shotPicture()
    }
    @IBAction func openImageLibrary(sender: AnyObject) {
        print("カメラロール")
        self.delegate.openLibraryPicture()
    }
    
    @IBAction func tapAlertViewBack(sender: AnyObject) {
        self.closeAlertView(sender: sender)
    }
    @IBAction func closeAlertView(sender: AnyObject) {
        print("閉じる")
        alertBackView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        
        UIView.animate(withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.3,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: {() -> Void  in
                self.alertView.center = CGPoint(x:self.frame.width/2, y:self.frame.height + (self.alertView.frame.height/2)) //最初は画面下部に隠す
            },
            completion:{(finished) -> Void in
                self.delegate.closeImageAlertView()
        })

    }
}
