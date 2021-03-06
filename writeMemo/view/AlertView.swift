import UIKit

protocol AlertViewDelegate:class{
    func tapYes(view:UIView)
    func tapNo(view:UIView)
    func removeAlertView()
}

class AlertView: UIView {
    
    weak var delegate:AlertViewDelegate! = nil
    
    var pinView:UIView = UIView()
    
    @IBOutlet weak var backAlertView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    
    
    class func instanceView() -> AlertView {
        return UINib(nibName: "AlertView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! AlertView
    }
    
    func showAlertView(){
        self.alertView.alpha = 1.0
        self.backAlertView.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.5)
        self.alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: {(BOOL) -> Void in
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.alertView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        })
    }
    
    func closeAlertView(){
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.alertView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: {(BOOL) -> Void in
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: {(BOOL) -> Void in
                self.delegate.removeAlertView()
            })
        })
    }
    
    @IBAction func tapYes(sender: AnyObject) {
        self.delegate.tapYes(view: pinView)
    }
    
    @IBAction func tapNo(sender: AnyObject) {
        self.delegate.tapNo(view: pinView)
    }
    
}
