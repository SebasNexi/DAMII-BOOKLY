//
//  LoginViewController.swift
//  DAMII-BOOKLY
//
//  Created by DAMII on 20/12/25.
//

import UIKit
import FirebaseAuth

class RegistroViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarTeclado()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✅ MODIFICADO: Sin NavigationController
        // navigationController?.setNavigationBarHidden(false, animated: animated) // ❌ COMENTADO
    }
    
    private func configurarTeclado() {
        txtNombre.delegate = self
        txtCorreo.delegate = self
        txtPassword.delegate = self
        
        txtCorreo.keyboardType = .emailAddress
        txtCorreo.autocapitalizationType = .none
        
        txtNombre.returnKeyType = .next
        txtCorreo.returnKeyType = .next
        txtPassword.returnKeyType = .done
        txtPassword.isSecureTextEntry = true
    }
    
    @IBAction func btnCrearCuenta(_ sender: UIButton) {
        // 1. Obtener valores
        guard let nombre = txtNombre.text, !nombre.isEmpty,
              let correo = txtCorreo.text, !correo.isEmpty,
              let password = txtPassword.text, !password.isEmpty else {
            
            mostrarAlerta(titulo: "Error", mensaje: "Completa todos los campos")
            return
        }
        
        // 2. Validar email
        let expresionRegular = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicado = NSPredicate(format: "SELF MATCHES %@", expresionRegular)
        
        if !predicado.evaluate(with: correo) {
            mostrarAlerta(titulo: "Error", mensaje: "Ingresa un email válido")
            return
        }
        
        // 3. Validar contraseña
        if password.count < 6 {
            mostrarAlerta(titulo: "Error", mensaje: "La contraseña debe tener al menos 6 caracteres")
            return
        }
        
        // 4. Deshabilitar botón
        sender.isEnabled = false
        sender.alpha = 0.7
        
        // 5. Registrar en Firebase
        Auth.auth().createUser(withEmail: correo, password: password) { [weak self] resultado, error in
            // 6. Rehabilitar botón
            sender.isEnabled = true
            sender.alpha = 1.0
            
            if let error = error {
                self?.mostrarErrorFirebase(error: error)
                return
            }
            
            // 7. Actualizar nombre en perfil
            if let usuario = Auth.auth().currentUser {
                let cambio = usuario.createProfileChangeRequest()
                cambio.displayName = nombre
                cambio.commitChanges { error in
                    if let error = error {
                        print("⚠️ Error al actualizar nombre: \(error.localizedDescription)")
                    }
                }
            }
            
            // 8. Mostrar mensaje de éxito
            self?.mostrarExitoRegistro(correo: correo)
        }
    }
    
    @IBAction func btnRegresar(_ sender: UIButton) {
        // ✅ MODIFICADO: Usar dismiss en lugar de pop
        dismiss(animated: true)
    }
    
    // MARK: - Métodos Helper
    
    private func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }
    
    private func mostrarErrorFirebase(error: Error) {
        var mensaje = error.localizedDescription
        
        // Traducir errores comunes
        if mensaje.contains("email already in use") {
            mensaje = "Este email ya está registrado"
        } else if mensaje.contains("weak password") {
            mensaje = "La contraseña es muy débil"
        } else if mensaje.contains("invalid email") {
            mensaje = "Email inválido"
        }
        
        mostrarAlerta(titulo: "Error", mensaje: mensaje)
    }
    
    private func mostrarExitoRegistro(correo: String) {
        let alerta = UIAlertController(
            title: "¡Cuenta Creada! 🎉",
            message: "Tu cuenta ha sido creada exitosamente.\n\nCorreo: \(correo)\n\nAhora puedes iniciar sesión.",
            preferredStyle: .alert
        )
        
        alerta.addAction(UIAlertAction(title: "Iniciar Sesión", style: .default) { [weak self] _ in
            self?.regresarALoginConCorreo(correo: correo)
        })
        
        present(alerta, animated: true)
    }
    
    private func regresarALoginConCorreo(correo: String) {
        // ✅ MODIFICADO: Usar dismiss y pasar datos al ViewController
        
        // 1. Cerrar esta pantalla
        dismiss(animated: true) {
            // 2. Pasar el correo al ViewController (Login)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController as? ViewController {
                rootVC.setEmailForLogin(correo)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtNombre:
            txtCorreo.becomeFirstResponder()
        case txtCorreo:
            txtPassword.becomeFirstResponder()
        case txtPassword:
            textField.resignFirstResponder()
            // Simular click en botón Crear Cuenta
            if let boton = view.viewWithTag(100) as? UIButton {
                btnCrearCuenta(boton)
            }
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
