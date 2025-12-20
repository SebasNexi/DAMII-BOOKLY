//
//  ViewController.swift
//  DAMII-BOOKLY
//
//  Created by DAMII on 20/12/25.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmail.delegate = self
        txtPassword.delegate = self
        checkCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Cargar último email registrado
        if let ultimoEmail = UserDefaults.standard.string(forKey: "ultimoEmailRegistrado") {
            txtEmail.text = ultimoEmail
            txtPassword.text = ""
            txtPassword.becomeFirstResponder()
            
            // Limpiar después de usar
            UserDefaults.standard.removeObject(forKey: "ultimoEmailRegistrado")
        }
    }
    
    // MARK: - Verificar Usuario Actual
    private func checkCurrentUser() {
        if Auth.auth().currentUser != nil {
            print("✅ Usuario ya autenticado")
            
            // ✅ MODIFICADO: COMENTAR navegación automática
            // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //     self.navigateToHome()
            // }
            
            // En su lugar, autocompletar email
            if let userEmail = Auth.auth().currentUser?.email {
                txtEmail.text = userEmail
            }
        }
    }

    // ✅ BOTÓN INGRESAR - MODIFICADO
    @IBAction func btnIngresar(_ sender: UIButton) {
        // 1. Deshabilitar el botón
            sender.isEnabled = false
            sender.alpha = 0.7
            
            // 2. Validar campos
            guard let email = txtEmail.text, !email.isEmpty,
                  let password = txtPassword.text, !password.isEmpty else {
                sender.isEnabled = true
                sender.alpha = 1.0
                showAlert(title: "Error", message: "Completa todos los campos")
                return
            }
            
            // 3. Validar email
            if !isValidEmail(email) {
                sender.isEnabled = true
                sender.alpha = 1.0
                showAlert(title: "Error", message: "Email inválido")
                return
            }
            
            // 4. Firebase Login
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                // 5. Rehabilitar botón
                sender.isEnabled = true
                sender.alpha = 1.0
                
                // 6. Manejar error
                if let error = error {
                    self?.showAlert(title: "Error",
                                  message: self?.getErrorMessage(from: error) ?? "Error desconocido")
                    return
                }
                
                // 7. Login exitoso - EJECUTAR SEGUE DIRECTAMENTE
                print("✅ Login exitoso")
                self?.performSegue(withIdentifier: "loginToMenu", sender: self)
            }    }
    
    // ✅ NUEVO MÉTODO: Mostrar éxito de login
    private func showLoginSuccess(email: String) {
        let alert = UIAlertController(
            title: "✅ LOGIN EXITOSO",
            message: "Usuario: \(email)\n\nIngreso Correcto.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // ✅ BOTÓN CREAR CUENTA - MODIFICADO
    @IBAction func btnCrearCuenta(_ sender: UIButton) {
        // ✅ MODIFICADO: Cargar desde Storyboard SIN segue
        
        // 1. Cargar Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 2. Intentar cargar RegistroViewController
        if let registroVC = storyboard.instantiateViewController(withIdentifier: "RegistroViewController") as? RegistroViewController {
            // 3. Presentar modalmente
            registroVC.modalPresentationStyle = .fullScreen
            present(registroVC, animated: true)
        } else {
            // 4. Si falla, mostrar error
            showAlert(title: "Error", message: "No se puede abrir el registro")
        }
    }
    
    // MARK: - Navigation
    private func navigateToHome() {
        // ✅ MODIFICADO: COMENTAR porque no hay segue
        // performSegue(withIdentifier: "showHome", sender: self) // ❌ COMENTADO
        
        print("⚠️ Sin NavigationController - No se puede navegar a Home")
    }
    
    // Validar formato de email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Traducir errores de Firebase a español
    private func getErrorMessage(from error: Error) -> String {
        let errorCode = AuthErrorCode(rawValue: error._code)
        
        switch errorCode {
        case .invalidEmail:
            return "El formato del email es inválido"
        case .wrongPassword:
            return "Contraseña incorrecta"
        case .userNotFound:
            return "No existe una cuenta con este email"
        case .userDisabled:
                return "Esta cuenta ha sido deshabilitada"
        case .networkError:
            return "Error de conexión. Verifica tu internet"
        default:
            return "Error al iniciar sesión"
        }
    }
    
    // Mostrar alerta
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                     message: message,
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Recibir email desde registro
    func setEmailForLogin(_ email: String) {
        txtEmail.text = email
        txtPassword.text = ""
        txtPassword.becomeFirstResponder()
    }
    
    // MARK: - Keyboard Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            textField.resignFirstResponder()
            // Simular click en el botón Ingresar
            if let button = view.viewWithTag(100) as? UIButton {
                btnIngresar(button)
            }
        }
        return true
    }
}
