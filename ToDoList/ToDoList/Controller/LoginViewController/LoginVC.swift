//
//  LoginVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/26/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    //MARK: - DECLERA VAR, LET
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - ACTION BUTTON
    @IBAction func actionButtonLogin(_ sender: Any) {
    }
    
    @IBAction func actionButtonRegister(_ sender: Any) {
        let registerVC = RegisterVC.init(nibName: "RegisterVC", bundle: nil)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initData()
    }
}

extension LoginVC {
    func initUI() {
        
    }
    
    func initData() {
        
    }
}
