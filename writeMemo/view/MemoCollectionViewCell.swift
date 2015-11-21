//
//  MemoCollectionViewCell.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/04.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

protocol MemoCollectionViewDelegate: class{
    func openDeleteAlert()
}

class MemoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var memoImage: UIImageView!
    @IBOutlet weak var memoTitle: UILabel!
    
    weak var delegate:MemoCollectionViewDelegate! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
        self.layer.borderColor = UIColor(red: 2.55, green: 2.55, blue: 2.55, alpha: 1.0).CGColor
        self.layer.borderWidth = 5
    }
    
    func setMemoInfo(title title:String,imageURL:String){
        
        memoTitle.text = title //メモタイトルをセット
        
        //メモ画像をセット
        var imageURL = NSURL(string: imageURL)
        //memoImage.sd_setImageWithURL(imageURL)
        
    }

    @IBAction func tapDeleteButton(sender: AnyObject) {
        self.delegate.openDeleteAlert()
    }
    
}
