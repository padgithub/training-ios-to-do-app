//
//  LoginVC.swift
//  ToDoList
//
//  Created by Nguyen Luong Anh on 7/26/19.
//  Copyright © 2019 Nguyen Luong Anh. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

private let buttonFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
private let buttonHeight = textFieldHeight
private let buttonHorizontalMargin = textFieldHorizontalMargin / 2
private let buttonImageDimension: CGFloat = 18
private let buttonVerticalMargin = (buttonHeight - buttonImageDimension) / 2
private let buttonWidth = (textFieldHorizontalMargin / 2) + buttonImageDimension
private let critterViewDimension: CGFloat = 160
private let critterViewFrame = CGRect(x: 0, y: 0, width: critterViewDimension, height: critterViewDimension)
private let critterViewTopMargin: CGFloat = 70
private let textFieldHeight: CGFloat = 37
private let textFieldHorizontalMargin: CGFloat = 16.5
private let textFieldSpacing: CGFloat = 22
private let textFieldTopMargin: CGFloat = 38.8
private let textFieldWidth: CGFloat = 206

class LoginVC: UIViewController {
    //MARK: - DECLERA VAR, LET
        private let critterView = CritterView(frame: critterViewFrame)
    @IBOutlet weak var button: UIButton!
    @IBAction func showHidePasswordButton(_ sender: Any) {
        button.tintColor = .text
        togglePasswordVisibility()
        
    }
    
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - ACTION BUTTON
    @IBAction func actionButtonLogin(_ sender: Any) {
        Auth.auth().signIn(withEmail: txtUserName.text ?? "", password: txtPassword.text ?? "") { (user, err) in
            if err != nil {
                if err!.localizedDescription == "The email address is badly formatted." {
                    KRProgressHUD.showError(withMessage: "Email sai định dạng")
                } else if err!.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                    KRProgressHUD.showError(withMessage: "Tài khoản không tồn tại")
                } else if err!.localizedDescription == "The password is invalid or the user does not have a password." {
                    KRProgressHUD.showError(withMessage: "Sai tài khoản hoặc mật khẩu")
                }
                
                print("Loi: \(err!.localizedDescription)")
            } else {
                TAppDelegate.fetchTag()
                let showTaskVC = ShowTaskVC.init(nibName: "ShowTaskVC", bundle: nil)
                self.navigationController?.pushViewController(showTaskVC, animated: true)
            }
        }
    }
    
    @IBAction func actionButtonRegister(_ sender: Any) {
        let registerVC = RegisterVC.init(nibName: "RegisterVC", bundle: nil)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private let notificationCenter: NotificationCenter = .default
    
    deinit {
        notificationCenter.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        txtUserName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        button.setImage(#imageLiteral(resourceName: "Password-hide"), for: .selected)
        initUI()
        initData()
        setUpView()
    }
}

extension LoginVC {
    func initUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func initData() {
        txtPassword.delegate = self
        txtUserName.delegate = self
    }
    
    ////////////////////
    
    private func setUpView() {
        view.backgroundColor = .dark
        
        view.addSubview(critterView)
        setUpCritterViewConstraints()
        
        setUpGestures()
        setUpNotification()
    }
    
    private func setUpGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        stopHeadRotation()
    }
    
    // MARK: - Notifications
    
    private func setUpNotification() {
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func applicationDidEnterBackground() {
        stopHeadRotation()
    }
    
    private func setUpCritterViewConstraints() {
        critterView.translatesAutoresizingMaskIntoConstraints = false
        critterView.heightAnchor.constraint(equalToConstant: critterViewDimension).isActive = true
        critterView.widthAnchor.constraint(equalTo: critterView.heightAnchor).isActive = true
        critterView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        critterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: critterViewTopMargin).isActive = true
    }
    
    private func fractionComplete(for textField: UITextField) -> Float {
        guard let text = textField.text, let font = textField.font else { return 0 }
        let textFieldWidth = textField.bounds.width - (2 * textFieldHorizontalMargin)
        return min(Float(text.size(withAttributes: [NSAttributedString.Key.font : font]).width / textFieldWidth), 1)
    }
    
    private func stopHeadRotation() {
        txtUserName.resignFirstResponder()
        txtPassword.resignFirstResponder()
        critterView.stopHeadRotation()
        passwordDidResignAsFirstResponder()
    }
    
    private func passwordDidResignAsFirstResponder() {
        critterView.isPeeking = false
        critterView.isShy = false
        button.isHidden = true
        button.isSelected = false
        txtPassword.isSecureTextEntry = true
    }

    private func togglePasswordVisibility() {
        button.isSelected.toggle()
        let isPasswordVisible = button.isSelected
        txtPassword.isSecureTextEntry = !isPasswordVisible
        critterView.isPeeking = isPasswordVisible
        
        // 🎩✨ Magic to fix cursor position when toggling password visibility
        if let textRange = txtPassword.textRange(from: txtPassword.beginningOfDocument, to: txtPassword.endOfDocument), let password = txtPassword.text {
            txtPassword.replace(textRange, withText: password)
        }
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let deadlineTime = DispatchTime.now() + .milliseconds(100)
        
        if textField == txtUserName {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { // 🎩✨ Magic to ensure animation starts
                let fractionComplete = self.fractionComplete(for: textField)
                self.critterView.startHeadRotation(startAt: fractionComplete)
                self.passwordDidResignAsFirstResponder()
            }
        }
        else if textField == txtPassword {
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) { // 🎩✨ Magic to ensure animation starts
                self.critterView.isShy = true
                self.button.isHidden = false
            }
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard !critterView.isActiveStartAnimating, textField == txtUserName else { return }
        
        let fractionComplete = self.fractionComplete(for: textField)
        critterView.updateHeadRotation(to: fractionComplete)
        
        if let text = textField.text {
            critterView.isEcstatic = text.contains("@")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUserName {
            txtUserName.resignFirstResponder()
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtPassword.resignFirstResponder()
            passwordDidResignAsFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtUserName {
            critterView.stopHeadRotation()
        }
    }
}
