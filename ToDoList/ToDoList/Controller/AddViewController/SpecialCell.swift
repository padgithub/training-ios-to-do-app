//
//  SpecialCell.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/9/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class SpecialCell: UICollectionViewCell {
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var viewButton: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewButton.layer.cornerRadius = 5
        viewButton.clipsToBounds = true
    }

}
