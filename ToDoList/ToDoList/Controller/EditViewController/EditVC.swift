//
//  EditVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/5/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class EditVC: UIViewController {
    var listTodo: [ListTask] = [
        ListTask(nameTask: "Do yoga", descriptionTask: "Do yoga", tagColor: "EE2375"),
        ListTask(nameTask: "Go Shopping", descriptionTask: "Buy bread", tagColor: "CD42FD"),
        ListTask(nameTask: "Go Shopping", descriptionTask: "Bananas", tagColor: "CD42FD"),
        ListTask(nameTask: "Meeting", descriptionTask: "Skype meeting whit Anh", tagColor: "01BACC"),
        ListTask(nameTask: "Running", descriptionTask: "Running", tagColor: "EE2375"),
        ListTask(nameTask: "Other", descriptionTask: "Other", tagColor: "8539F9"),
        ListTask(nameTask: "Do yoga", descriptionTask: "Do yoga", tagColor: "EE2375"),
        ListTask(nameTask: "Other", descriptionTask: "Other", tagColor: "8539F9"),
        ListTask(nameTask: "Do yoga", descriptionTask: "Do yoga", tagColor: "EE2375")
    ]
    
    @IBOutlet weak var toDoListTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnSearchButton: UIButton!
    @IBAction func btnSearch(_ sender: Any) {
        searchBar.isHidden = !searchBar.isHidden
        btnSearchButton.isHidden = !btnSearchButton.isHidden
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
}

extension EditVC: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTodo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CellTask
        cell.taskData = listTodo[indexPath.row]
        cell.initData()
        return cell
    }
}

extension EditVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/9
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            self.listTodo.remove(at: indexPath.row)
            self.toDoListTable.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        action.image = UIImage(named: "ic_remove")
        action.backgroundColor = UIColor("EE2375", alpha: 1.0)
        
        return action
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cell = toDoListTable.cellForRow(at: indexPath) as? CellTask
        cell!.backgroundColor = UIColor("EE2375", alpha: 0.2)
        cell!.isHide = true
        cell!.setHide()
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        let cell = toDoListTable.cellForRow(at: indexPath!) as? CellTask
        cell!.backgroundColor = .clear
        cell!.isHide = false
        cell!.setHide()
    }
}

extension EditVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = !searchBar.isHidden
        btnSearchButton.isHidden = !btnSearchButton.isHidden
    }
}


