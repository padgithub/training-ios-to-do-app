//
//  AddPeopleCell.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/22/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class AddPeopleCell: UICollectionViewCell {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbAvatar: UILabel!
    
    var isHide = true
    var dataLabel = "nil"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgAvatar.layer.borderWidth = 1
        imgAvatar.layer.masksToBounds = false
        imgAvatar.layer.borderColor = UIColor.black.cgColor
        imgAvatar.layer.cornerRadius = imgAvatar.frame.height/2
        imgAvatar.clipsToBounds = true
        
        lbAvatar.layer.borderWidth = 1
        lbAvatar.layer.masksToBounds = false
        lbAvatar.layer.borderColor = UIColor.black.cgColor
        lbAvatar.layer.cornerRadius = lbAvatar.frame.height/2
        lbAvatar.clipsToBounds = true
    }
    func config() {
        lbAvatar.isHidden = isHide
        lbAvatar.text = dataLabel
    }
    

}
