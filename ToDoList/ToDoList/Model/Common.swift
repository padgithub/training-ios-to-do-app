//
//  Common.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/23/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

//MARK: - Support func
protocol NibReusable: class {
    static var reuseIdentifier: String { get }
    static var nibName: String { get }
}

extension NibReusable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
    static var reuseIdentifier: String {
        return nibName
    }
}

extension UITableViewCell: NibReusable { }

extension UICollectionViewCell: NibReusable { }

extension UITableViewHeaderFooterView: NibReusable { }

extension UICollectionView {
    func register<Cell: NibReusable>(_ cell: Cell.Type) {
        let nib = UINib(nibName: cell.nibName, bundle: Bundle(for: cell))
        register(nib, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
    func dequeueReusableCell<Cell: NibReusable>(forIndexPath indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.reuseIdentifier)")
        }
        return cell
    }
}

extension UITableView {
    func register<Cell: NibReusable>(_ cell: Cell.Type) {
        let nib = UINib(nibName: Cell.nibName, bundle: Bundle(for: cell))
        register(nib, forCellReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReusableCell<Cell: NibReusable>(forIndexPath indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(Cell.reuseIdentifier)")
        }
        return cell
    }
    
    func registerHeaderFooterView<Cell: NibReusable>(_ cell: Cell.Type) {
        let nib = UINib(nibName: Cell.nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func dequeueReusableHeaderFooterView<Cell: NibReusable>() -> Cell {
        guard let header = dequeueReusableHeaderFooterView(withIdentifier: Cell.reuseIdentifier) as? Cell else {
            fatalError("Could not dequeue header with identifier: \(Cell.reuseIdentifier)")
        }
        return header
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}


let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    var urlImageString: String?
    
    func loadImageUsingCache(withUrl urlPath : String, frame: CGRect) {
        urlImageString = urlPath
        let urlString = URL(string: urlPath)
        if urlString == nil {return}
        self.image = nil
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlPath as NSString)  {
            self.image = cachedImage
            return
        }
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = center
        activityIndicator.frame = CGRect(x: frame.width/2 - 50/2, y: frame.height/2 - 50/2, width: 50, height: 50)
        activityIndicator.style = .gray
        // if not, download image from url
        
        URLSession.shared.dataTask(with: urlString!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let imageToCache = UIImage(data: data!) {
                    if self.urlImageString == urlPath {
                        self.image = imageToCache
                        activityIndicator.stopAnimating()
                    }
                    imageCache.setObject(imageToCache, forKey: urlPath as NSString)
                }
            }
        }).resume()
    }
}
