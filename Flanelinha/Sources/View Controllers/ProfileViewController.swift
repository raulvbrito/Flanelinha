//
//  ProfileViewController.swift
//  Flanelinha
//
//  Created by Raul Brito on 30/04/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var loginToggleButton: UIButton!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	
	lazy var userRef: DatabaseReference = Database.database().reference().child("users")
	
	private var userRefHandle: DatabaseHandle?
	
	var loginForm = false
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	@IBAction func login(_ sender: Any) {
		if !loginForm {
			Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
				if let error = error {
					print(error.localizedDescription)
					
					let alert = UIAlertController(title: "Atenção", message: "Falha ao cadastrar", preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
					
					self.present(alert, animated: true, completion: nil)
				} else if let result = result {
					print(result)
					
					let alert = UIAlertController(title: "Atenção", message: "Você foi cadastrado", preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
						self.dismiss(animated: true, completion: nil)
					}))
					
					self.present(alert, animated: true, completion: nil)
				}
			}
		} else {
			Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
				if let error = error{
					print(error.localizedDescription)
					
					let alert = UIAlertController(title: "Atenção", message: "Falha ao logar", preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
					
					self.present(alert, animated: true, completion: nil)
				} else if let result = result {
					print(result)
					
					let alert = UIAlertController(title: "Atenção", message: "Você está logado", preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
						self.dismiss(animated: true, completion: nil)
					}))
					
					self.present(alert, animated: true, completion: nil)
				}
			}
        }
	}
	
	@IBAction func toggleLogin(_ sender: Any) {
		loginForm = !loginForm
		
		if loginForm {
			titleLabel.text = "Login"
			loginToggleButton.setTitle("Mudar para Cadastro", for: .normal)
			loginButton.setTitle("Entrar", for: .normal)
		} else {
			titleLabel.text = "Cadastro"
			loginToggleButton.setTitle("Mudar para Login", for: .normal)
			loginButton.setTitle("Cadastrar", for: .normal)
		}
	}
	
	@IBAction func close(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}
