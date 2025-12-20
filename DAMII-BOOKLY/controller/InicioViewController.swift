//
//  InicioViewController.swift
//  DAMII-BOOKLY
//
//  Created by DAMII on 20/12/25.
//

import UIKit

class InicioViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func btnComenzar(_ sender: UIButton) {
        performSegue(withIdentifier: "showLogin", sender: self)
    }
    
}
