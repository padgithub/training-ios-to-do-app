//
//  DetailImageCell.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/24/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import SDWebImage

class DetailImageCell: UICollectionViewCell {
    @IBOutlet weak var imgDetail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(path: URL) {
        imgDetail.sd_setImage(with: path, completed: nil)
    }
}
