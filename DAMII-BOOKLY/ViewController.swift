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
            
            // Autocompletar email
            if let userEmail = Auth.auth().currentUser?.email {
                txtEmail.text = userEmail
            }
        }
    }

    // ✅ BOTÓN INGRESAR - REDIRIGIR A TAB BAR CONTROLLER
    @IBAction func btnIngresar(_ sender: UIButton) {
        print("🔄 Iniciando proceso de login...")
        
        // 1. Deshabilitar UI
        sender.isEnabled = false
        sender.alpha = 0.7
        view.isUserInteractionEnabled = false
        
        // 2. Obtener y limpiar datos
        let email = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = txtPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // 3. Validar campos
        guard !email.isEmpty else {
            enableUI(sender: sender)
            showAlert(title: "Error", message: "Ingresa tu email")
            txtEmail.becomeFirstResponder()
            return
        }
        
        guard !password.isEmpty else {
            enableUI(sender: sender)
            showAlert(title: "Error", message: "Ingresa tu contraseña")
            txtPassword.becomeFirstResponder()
            return
        }
        
        guard isValidEmail(email) else {
            enableUI(sender: sender)
            showAlert(title: "Error", message: "Email inválido")
            txtEmail.becomeFirstResponder()
            return
        }
        
        // 4. Firebase Login
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            // 5. Habilitar UI
            self?.enableUI(sender: sender)
            
            // 6. Manejar error
            if let error = error {
                let errorMessage = self?.getErrorMessage(from: error) ?? "Credenciales incorrectas"
                self?.showAlert(title: "Error", message: errorMessage)
                self?.txtPassword.text = ""
                self?.txtPassword.becomeFirstResponder()
                return
            }
            
            // 7. Login exitoso - MOSTRAR MENSAJE PERSONALIZADO
            print("✅ Login exitoso")
            
            // ✅ NUEVO: Mostrar mensaje de acceso con el formato solicitado
            self?.showAccessSuccessMessage(email: email)
        }
    }
    
    // ✅ NUEVO MÉTODO: Mostrar mensaje de acceso exitoso
    private func showAccessSuccessMessage(email: String) {
        let alert = UIAlertController(
            title: "✅ Accediste correctamente",
            message: "Usuario: \(email)",
            preferredStyle: .alert
        )
        
        // Personalizar el mensaje (opcional)
        let attributedMessage = NSMutableAttributedString(
            string: "✅ Accediste correctamente\n\nUsuario: \(email)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.darkGray
            ]
        )
        
        // Resaltar el check y el email
        let checkRange = (attributedMessage.string as NSString).range(of: "✅")
        if checkRange.location != NSNotFound {
            attributedMessage.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: checkRange)
        }
        
        let userRange = (attributedMessage.string as NSString).range(of: "Usuario: \(email)")
        if userRange.location != NSNotFound {
            attributedMessage.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: userRange)
        }
        
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        // OPCIÓN 1: Con título personalizado también
        let attributedTitle = NSAttributedString(
            string: "Acceso Exitoso",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.systemGreen
            ]
        )
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        present(alert, animated: true)
        
        // Redirigir al TabBarController después de 2 segundos (da tiempo a leer el mensaje)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true) {
                self.navigateToTabBarController()
            }
        }
    }
    
    // ✅ NAVEGACIÓN A TAB BAR CONTROLLER
    private func navigateToTabBarController() {
        print("🚀 Navegando a Tab Bar Controller...")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Usar el ID exacto que me dijiste: "TabBarController"
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            print("✅ Encontrado Tab Bar Controller con ID: TabBarController")
            
            // Configurar presentación
            tabBarController.modalPresentationStyle = .fullScreen
            tabBarController.modalTransitionStyle = .coverVertical
            present(tabBarController, animated: true, completion: nil)
            
        } else {
            print("❌ No se encontró TabBarController con ID 'TabBarController'")
            
            // Intentar con otros IDs como fallback
            let alternativeIDs = ["MainTabBarController", "HomeTabBarController"]
            for tabBarID in alternativeIDs {
                if let tabBarController = storyboard.instantiateViewController(withIdentifier: tabBarID) as? UITabBarController {
                    print("✅ Encontrado con ID alternativo: \(tabBarID)")
                    tabBarController.modalPresentationStyle = .fullScreen
                    present(tabBarController, animated: true, completion: nil)
                    return
                }
            }
            
            showAlert(title: "Error", message: "No se pudo cargar la aplicación principal")
        }
    }
    
    // ✅ BOTÓN CREAR CUENTA
    @IBAction func btnCrearCuenta(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let registroVC = storyboard.instantiateViewController(withIdentifier: "RegistroViewController") as? RegistroViewController {
            registroVC.modalPresentationStyle = .fullScreen
            present(registroVC, animated: true)
        } else {
            showAlert(title: "Error", message: "No se puede abrir el registro")
        }
    }
    
    // ✅ HABILITAR UI
    private func enableUI(sender: UIButton) {
        sender.isEnabled = true
        sender.alpha = 1.0
        view.isUserInteractionEnabled = true
    }
    
    // ✅ VALIDAR EMAIL
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // ✅ TRADUCIR ERRORES DE FIREBASE
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
            return "Error al iniciar sesión. Verifica tus credenciales"
        }
    }
    
    // ✅ MOSTRAR ALERTA (para errores)
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                     message: message,
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // ✅ RECIBIR EMAIL DESDE REGISTRO
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
