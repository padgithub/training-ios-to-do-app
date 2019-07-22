//
//  EditVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/5/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import SwiftyJSON

class EditVC: UIViewController {
    
    var tagSelected: TypeTag!
    var isDoing = false
    
    var listTodo: [ListTask] = []
    var filteredList = [ListTask]()
    var isSearch = false
    
    @IBOutlet weak var toDoListTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnSearchButton: UIButton!
    @IBAction func btnSearch(_ sender: Any) {
        searchBar.isHidden = !searchBar.isHidden
        btnSearchButton.isHidden = !btnSearchButton.isHidden
    }
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
    }
}

extension EditVC{
    func initUI(){
        toDoListTable.register(CellTask.self)
        toDoListTable.estimatedRowHeight = 80.0
        toDoListTable.rowHeight = UITableView.automaticDimension
        
    }
    
    func initData(){
        toDoListTable.dataSource = self
        toDoListTable.delegate = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    func fetchData() {
        if (tagSelected != nil) {
            fetchTaskWithTag(tag: tagSelected)
        } else if isDoing {
            fetchDataDoing()
        } else {
            fetchDataNormal()
        }
    }
    
    func fetchTaskWithTag(tag: TypeTag) {
        TAppDelegate.db.collection("Task").whereField("tagID", isEqualTo: tag.firebaseKey).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.listTodo.removeAll()
                for document in querySnapshot!.documents {
                    let obj = ListTask.init(data: JSON.init(document.data()))
                    self.listTodo.append(obj)
                }
                
                if self.listTodo.count > 0 {
                    self.listTodo = self.listTodo.sorted(by: { $0.timeEnd > $1.timeEnd })
                    self.filteredList = self.listTodo
                    self.toDoListTable.reloadData()
                }
            }
        }
    }
    
    func fetchDataNormal() {
        TAppDelegate.db.collection("Task").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.listTodo.removeAll()
                for document in querySnapshot!.documents {
                    let obj = ListTask.init(data: JSON.init(document.data()))
                    self.listTodo.append(obj)
                }
                if self.listTodo.count > 0 {
                    self.listTodo = self.listTodo.sorted(by: { $0.timeEnd > $1.timeEnd })
                    self.filteredList = self.listTodo
                    self.toDoListTable.reloadData()
                }
            }
        }
    }
    
    func fetchDataDoing() {
         let currentDay = Date().timeIntervalSince1970
        
        TAppDelegate.db.collection("Task").whereField("timeEnd", isGreaterThanOrEqualTo: currentDay).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.listTodo.removeAll()
                for document in querySnapshot!.documents {
                    let obj = ListTask.init(data: JSON.init(document.data()))
                    self.listTodo.append(obj)
                }
                if self.listTodo.count > 0 {
                    self.listTodo = self.listTodo.sorted(by: { $0.timeEnd > $1.timeEnd })
                    self.filteredList = self.listTodo
                    self.toDoListTable.reloadData()
                }
            }
        }
    }
}

extension EditVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return filteredList.count
        } else {
            return listTodo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CellTask
        if isSearch {
            cell.taskData = filteredList[indexPath.row]
            cell.handleEdit = {
                let addVC = AddVC.init(nibName: "AddVC", bundle: nil)
                addVC.isEdit = true
                addVC.taskEdit = self.filteredList[indexPath.row]
                self.navigationController?.pushViewController(addVC, animated: true)
            }
            cell.initData()
        } else {
            cell.taskData = listTodo[indexPath.row]
            cell.handleEdit = {
                let addVC = AddVC.init(nibName: "AddVC", bundle: nil)
                addVC.isEdit = true
                addVC.taskEdit = self.listTodo[indexPath.row]
                self.navigationController?.pushViewController(addVC, animated: true)
            }
            cell.initData()
        }
        return cell
    }
}

extension EditVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/9
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let taskRemove = self.listTodo[indexPath.row]
            self.deleteTask(taskRemove)
            self.listTodo.remove(at: indexPath.item)
            self.toDoListTable.deleteRows(at: [indexPath], with: .automatic)
            self.toDoListTable.reloadData()
            completion(true)
        }
    
        action.image = UIImage(named: "ic_remove")
        action.backgroundColor = UIColor("EE2375", alpha: 1.0)
        
        return action
    }
    
    func deleteTask(_ taskRemove : ListTask) {
        TAppDelegate.db.collection("Task").document("\(taskRemove.taskID)").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cell = toDoListTable.cellForRow(at: indexPath) as? CellTask
        cell!.backgroundColor = UIColor("EE2375", alpha: 0.2)
        cell!.isHide = true
        cell!.setHide()
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        let cell = toDoListTable.cellForRow(at: indexPath!) as? CellTask
        cell?.backgroundColor = .clear
        cell?.isHide = false
        cell?.setHide()
    }
}

extension EditVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = !searchBar.isHidden
        btnSearchButton.isHidden = !btnSearchButton.isHidden
        fetchData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            
            filteredList = listTodo.filter({( item : ListTask) -> Bool in
                return item.nameTask.lowercased().contains(searchText.lowercased())
            })
        isSearch = true
        }
        toDoListTable.reloadData()
    }
}

