//
//  TypeViewCell.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/4/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class TypeViewCell: UICollectionViewCell {
    @IBOutlet weak var lbTagType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func cofig(typeTag: TypeTag) {
        lbTagType.layer.cornerRadius = 3
        lbTagType.clipsToBounds = true
        lbTagType.textColor = UIColor.white
        lbTagType.backgroundColor = UIColor(typeTag.backGround, alpha: 1.0)
        lbTagType.text = typeTag.textTag
    }
}

extension UIColor {
    convenience init(_ hex:String, alpha: CGFloat) {
        let scanner = Scanner(string: hex)
        
        if (hex.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

