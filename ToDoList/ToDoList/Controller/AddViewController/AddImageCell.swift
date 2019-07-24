//
//  AddImageCell.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/22/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import SDWebImage

class AddImageCell: UICollectionViewCell {
    @IBOutlet weak var imgDesc: CustomImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(path: URL) {
//        let url = URL(fileURLWithPath: path)
        imgDesc.sd_setImage(with: path, completed: nil)
        
//        imgDesc.loadImageUsingCache(withUrl: path, frame: self.imgDesc.frame)
        
////        if FileManager.default.fileExists(atPath: path) {
//
////        }
    }
}
