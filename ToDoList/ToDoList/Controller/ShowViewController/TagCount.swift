//
//  TagCount.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/10/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class TagCount: UICollectionViewCell {
    @IBOutlet weak var imgTag: UIImageView!
    @IBOutlet weak var lbNametag: UILabel!
    @IBOutlet weak var viewTag: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func cofig(typeTag: TypeTag) {
        imgTag.layer.masksToBounds = false
        DispatchQueue.main.async {
            self.imgTag.layer.cornerRadius = self.imgTag.bounds.height/2
        }
        imgTag.clipsToBounds = true
        imgTag.backgroundColor = UIColor(typeTag.backGround, alpha: 1.0)
        lbNametag.text = typeTag.textTag
    }
}
