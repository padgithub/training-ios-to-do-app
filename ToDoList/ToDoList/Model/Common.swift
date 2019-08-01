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

//
//  AlertHelper.swift
//  Task
//
//  Created by Hoa on 3/31/18.
//  Copyright © 2018 SDC. All rights reserved.
//

import UIKit

public typealias ActionHandler = (_ action: UIAlertAction) -> ()
public typealias AttributedActionTitle = (title: String, style: UIAlertAction.Style)

class AlertController: UIAlertController {
    @objc
    func hideAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
}

public extension UIAlertController {
    
    class func present(style: UIAlertController.Style = .alert, title: String?, message: String?, actionTitles: [String]?, handler: ActionHandler? = nil) -> UIAlertController {
        let rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!
        return self.presentFromViewController(viewController: rootViewController, style: style, title: title, message: message, actionTitles: actionTitles, handler: handler)
    }
    
    class func present(style: UIAlertController.Style = .alert, title: String?, message: String?, attributedActionTitles: [AttributedActionTitle]?, handler: ActionHandler? = nil) -> UIAlertController {
        let rootViewController = UIApplication.shared.delegate!.window!!.rootViewController!
        return self.presentFromViewController(viewController: rootViewController, style: style, title: title, message: message, attributedActionTitles: attributedActionTitles, handler: handler)
    }
    
    class func presentFromViewController(viewController: UIViewController, style: UIAlertController.Style = .alert, title: String?, message: String?, actionTitles: [String]?, handler: ActionHandler? = nil) -> UIAlertController {
        return self.presentFromViewController(viewController: viewController, style: style, title: title, message: message, attributedActionTitles: actionTitles?.map({ (title) -> AttributedActionTitle in return (title: title, style: .default) }), handler: handler)
    }
    
    class func presentFromViewController(viewController: UIViewController, style: UIAlertController.Style = .alert, title: String?, message: String?, attributedActionTitles: [AttributedActionTitle]?, handler: ActionHandler? = nil) -> UIAlertController {
        let alertController = AlertController(title: title, message: message, preferredStyle: style)
        if let _attributedActionTitles = attributedActionTitles {
            for attributedActionTitle in _attributedActionTitles {
                let buttonAction = UIAlertAction(title: attributedActionTitle.title, style: attributedActionTitle.style, handler: { (action) -> Void in
                    handler?(action)
                })
                alertController.addAction(buttonAction)
            }
        }
        NotificationCenter.default.addObserver(alertController, selector: #selector(AlertController.hideAlertController), name: NSNotification.Name(rawValue: NotificationCenterKey.DismissAllAlert), object: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = viewController.view
            alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            alertController.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            viewController.present(alertController, animated: true) {
                print("option menu presented")
            }
        } else {
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        
        return alertController
    }
}

// MARK:
public extension UIViewController {
    func presentAlert(style: UIAlertController.Style = .alert, title: String?, message: String?, actionTitles: [String]?, handler: ActionHandler? = nil) -> UIAlertController {
        return UIAlertController.presentFromViewController(viewController: self, style: style, title: title, message: message, actionTitles: actionTitles, handler: handler)
    }
    
    func presentAlert(style: UIAlertController.Style = .alert, title: String?, message: String?, attributedActionTitles: [AttributedActionTitle]?, handler: ActionHandler? = nil) -> UIAlertController {
        return UIAlertController.presentFromViewController(viewController: self, style: style, title: title, message: message, attributedActionTitles: attributedActionTitles, handler: handler)
    }
    
    var topPresentedViewController: UIViewController? {
        get {
            var target: UIViewController? = self
            while (target?.presentedViewController != nil) {
                target = target?.presentedViewController
            }
            return target
        }
    }
    
    var topVisibleViewController: UIViewController? {
        get {
            if let nav = self as? UINavigationController {
                return nav.topViewController?.topVisibleViewController
            }
            else if let tabBar = self as? UITabBarController {
                return tabBar.selectedViewController?.topVisibleViewController
            }
            return self
        }
    }
    
    var topMostViewController: UIViewController? {
        get {
            return self.topPresentedViewController?.topVisibleViewController
        }
    }
}

class NotificationCenterKey {
    static let SelectedMenu = "SelectedMenu"
    static let DismissAllAlert = "DismissAllAlert"
}

extension Date {
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    func string(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
    
    func stringWithTimeZone( timeZone: String, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
    
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    var secondsSince1970: Int {
        return Int((self.timeIntervalSince1970).rounded())
    }
    
    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    init(seconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    init(string: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self = dateFormatter.date(from: string)!
    }
    
    func getElapsedInterval() -> String {
        let unitFlags = Set<Calendar.Component>([.day, .weekOfMonth, .month, .year, .hour , .minute, .second])
        var interval = Calendar.current.dateComponents(unitFlags, from: self,  to: Date())
        if interval.year! > 0 {
            return "\(interval.year!)" + " " + "năm trước"
        }
        if interval.month! > 0 {
            return "\(interval.month!)" + " " + "tháng trước"
        }
        if interval.weekOfMonth! > 0 {
            return "\(interval.weekOfMonth!)" + " " + "tuần trước"
        }
        if interval.day! > 0 {
            return "\(interval.day!)" + " " + "ngày trước"
        }
        if interval.hour! > 0 {
            return "\(interval.hour!)" + " " + "giờ trước"
        }
        if interval.minute! > 0 {
            return "\(interval.minute!)" + " " + "phút trước"
        }
        
        if interval.second! > 0 {
            return "Vừa xong"
        }
        return "Vừa xong"
    }
    
    var startDate: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self) ?? self
    }
    var endDate: Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
}
