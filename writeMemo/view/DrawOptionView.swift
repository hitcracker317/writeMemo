import UIKit

protocol DrawOptionViewDelegate: class {
    //プロトコル：デリゲートメソッドを定義
    func setThickness(thickness thickness:Int) //太さ
    func setColor(color color:UIColor) //色
    func changeEditMode(isPaint isPaint:Bool) //ペンか消しゴムか
}

class DrawOptionView: UIView, ColorPalletViewDelegate {

    weak var delegate: DrawOptionViewDelegate! = nil
    
    @IBOutlet weak var palletIconImage: UIImageView!
    @IBOutlet weak var thickIconImage: UIImageView!
    @IBOutlet weak var thinIconImage: UIImageView!
    
    @IBOutlet weak var changeDrawModeButton: UIButton!
    @IBOutlet weak var changeEraserModeButton: UIButton!

    var isDrawMode:Bool = true //鉛筆モードか消しゴムモードか
    
    @IBOutlet weak var colorPalletView: ColorPaletteView!
    
    class func instance() -> DrawOptionView {
        return UINib(nibName: "DrawOptionView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! DrawOptionView
    }
    
    required init?(coder aDecoder: NSCoder) {
        //xibやstoryboardにviewを配置した時に呼ばれる
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // XIB読み込みんだ際に呼ばれるメソッド
        colorPalletView.colorPalletDelgate = self
    }
    
    @IBAction func changeThickness(sender: UISlider) {
        //描画の太さを変更
        self.delegate.setThickness(thickness: Int(sender.value))
    }
    
    func setColor(color: UIColor) {
        //鉛筆の色を変更
        self.changeDrawMode(sender: color) //消しゴムモードの場合は鉛筆モードに変更
        self.delegate.setColor(color: color)
    }
    
    @IBAction func changeDrawMode(sender: AnyObject) {
        //鉛筆モードに変更
        if(!isDrawMode){
            //TODO:鉛筆モードを選択していることを明示するカーソル的なものを用意
            //TODO:太さのアイコンを鉛筆のアイコンに変更
            isDrawMode = true
            changeDrawModeButton.backgroundColor = UIColor(red:0.86, green:0.33, blue:0.20, alpha:1.0)
            changeEraserModeButton.backgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
            self.delegate.changeEditMode(isPaint: true)
        }
    }
    
    @IBAction func changeEraserMode(sender: AnyObject) {
        //消しゴムモードに変更
        if(isDrawMode){
            //TODO:消しゴムモードを選択していることを明示するカーソル的なものを用意
            //TODO:太さのアイコンを消しゴムのアイコンに変更
            isDrawMode = false
            changeDrawModeButton.backgroundColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)
            changeEraserModeButton.backgroundColor = UIColor(red:0.86, green:0.33, blue:0.20, alpha:1.0)
            self.delegate.changeEditMode(isPaint: false)
        }
    }
}
