//
//  MemoCollectionViewCell.swift
//  writeMemo
//
//  Created by 前田 晃良 on 2015/11/04.
//  Copyright (c) 2015年 A.M. All rights reserved.
//

import UIKit

class MemoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var memoImage: UIImageView!
    @IBOutlet weak var memoTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setMusicInfo(#title:String,imageURL:String){
        
        memoTitle.text = title //メモタイトルをセット
        
        //メモ画像をセット
        var imageURL = NSURL(string: imageURL)
        //memoImage.sd_setImageWithURL(imageURL)
        
    }

    
}
