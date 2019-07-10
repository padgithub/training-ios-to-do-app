//
//  AddVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/4/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

enum TypeCell {
    case nomal
    case special
}

class AddVC: UIViewController {
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var txtTextView: UITextView!
    @IBOutlet weak var dateTimeToShow: UILabel!
    @IBOutlet weak var viewChooseDate: UIView!
    
    var arrTag: [TypeTag] = [TypeTag(textTag: "Work", backGround: "42AAFD"),
                             TypeTag(textTag: "Personal", backGround: "01BACC"),
                             TypeTag(textTag: "Shopping", backGround: "CD42FD"),
                             TypeTag(textTag: "Health", backGround: "EE2375"),
                             TypeTag(textTag: "Other", backGround: "8539F9"),
                             TypeTag(textTag: "", backGround: "", type: .special)
                             ]
    
    @IBOutlet weak var typeCollection: UICollectionView!
    @IBOutlet weak var btnAddTask: UIButton!
    
    //MARK: - Declaration DatePickerView
    @IBOutlet weak var dateChoose: UIDatePicker!
    @IBOutlet weak var txtChooseDate: UILabel!
    @IBOutlet weak var imgShowDate: UIImageView!
    
    let dateFormatter = DateFormatter()
    var startDate = ""
    var endDate = ""
    
    @IBAction func actionDone(_ sender: Any) {
        if txtChooseDate.tag != 0 {
            txtTextView.text = "Choose Start Date"
            viewDatePicker.isHidden = true
            
            dateFormatter.dateFormat = "dd-MM h:m"
            endDate = dateFormatter.string(from: dateChoose.date)
            dateTimeToShow.text = "\(startDate) - \(endDate)"
            
            //dateTimeToShow.sizeToFit()
            imgShowDate.updateFocusIfNeeded()
        }else
        {
            txtChooseDate.tag = 1
            txtChooseDate.text = "Choose End Date"
            
            dateFormatter.dateFormat = "dd-MM h:m"
            startDate = dateFormatter.string(from: dateChoose.date)
            print(startDate)
        }
       
    }
    @IBAction func actionCancel(_ sender: Any) {
        viewDatePicker.isHidden = true
        txtChooseDate.text = "Choose Start Date"
        txtChooseDate.tag = 0
    }
    
    //MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()

        let tap = UITapGestureRecognizer(target: self, action: #selector(AddVC.tapFunction))
        viewChooseDate.isUserInteractionEnabled = true
        viewChooseDate.addGestureRecognizer(tap)
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        viewDatePicker.isHidden = !viewDatePicker.isHidden
    }
}
//MARK: - Set tag collection view
extension AddVC: UITextViewDelegate,UINavigationBarDelegate {
    func initUI() {
        typeCollection.register(TypeViewCell.self)
        typeCollection.register(SpecialCell.self)
        
        //MARK: - Layout collection view cell
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: typeCollection.frame.width/3 - 10, height: typeCollection.frame.height/3)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        typeCollection!.collectionViewLayout = layout
        
        btnAddTask.layer.cornerRadius = 10
        btnAddTask.clipsToBounds = true
        btnAddTask.layer.borderWidth = 1
        btnAddTask.layer.borderColor = UIColor("979797", alpha: 1.0).cgColor
        
        txtTextView.text = "Description..."
        txtTextView.textColor = UIColor.lightGray
    }
    
    func initData() {
        typeCollection.dataSource = self
        typeCollection.delegate = self
    }
}

//MARK: - Setup CollectionView
extension AddVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrTag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = arrTag[indexPath.row]
        switch tag.type {
        case .special:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as SpecialCell
            cell.btnAdd.addTarget(self, action: #selector(addButtonTapped), for: UIControl.Event.touchUpInside)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TypeViewCell
            cell.cofig(typeTag: tag)
            return cell
        }
    }
    
    @objc func addButtonTapped(sender: UIButton) {
        print("Show UI to add new tag")
        arrTag.insert(TypeTag(textTag: "Hello", backGround: "000000"), at: arrTag.count - 1)
        typeCollection.reloadData()
    }
}

extension AddVC : UICollectionViewDelegate {
    
}

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
