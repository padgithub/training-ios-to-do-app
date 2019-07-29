//
//  LoginVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/26/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    //MARK: - DECLERA VAR, LET
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - ACTION BUTTON
    @IBAction func actionButtonLogin(_ sender: Any) {
        Auth.auth().signIn(withEmail: txtUserName.text ?? "", password: txtPassword.text ?? "") { (user, err) in
            if err != nil {
                print(err!)
            } else {
                let showTaskVC = ShowTaskVC.init(nibName: "ShowTaskVC", bundle: nil)
                self.navigationController?.pushViewController(showTaskVC, animated: true)
            }
        }
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
        txtPassword.delegate = self
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtPassword.resignFirstResponder()
        return true
    }
}
