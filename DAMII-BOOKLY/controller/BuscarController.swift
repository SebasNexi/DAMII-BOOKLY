import UIKit

class BuscarController: UIViewController {
    
    private let gradient = CAGradientLayer()
    
    @IBOutlet weak var btnCiencia: UIButton!
    @IBOutlet weak var btnFantasia: UIButton!
    @IBOutlet weak var btnFiccion: UIButton!
    @IBOutlet weak var btnRomance: UIButton!
    @IBOutlet weak var btnTerror: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupBotones()
    }
    
    private func setupGradient() {
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor(red: 45/255, green: 100/255, blue: 50/255, alpha: 1).cgColor
        ]
        gradient.locations = [0.0, 0.6]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupBotones() {
        // Configurar estilo de botones
        let botones = [btnCiencia, btnFantasia, btnFiccion, btnRomance, btnTerror]
        
        for boton in botones {
            boton?.layer.cornerRadius = 10
            boton?.layer.borderWidth = 2
            boton?.layer.borderColor = UIColor.white.cgColor
            boton?.backgroundColor = UIColor(white: 1, alpha: 0.2)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    // MARK: - Navegación común
    private func navegarAGenero(_ genero: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let destinoVC = storyboard.instantiateViewController(
            withIdentifier: "BuscarLibroController") as? BuscarLibroController {
            
            //destinoVC.generoSeleccionado = genero
            navigationController?.pushViewController(destinoVC, animated: true)
        }
    }
    
    // MARK: - IBActions
    @IBAction func btnCiencia(_ sender: Any) {
        navegarAGenero("Ciencia")
    }
    
    @IBAction func btnFantasia(_ sender: Any) {
        navegarAGenero("Fantasia")
    }
    
    @IBAction func btnFiccion(_ sender: Any) {
        navegarAGenero("Ficcion")
    }
    
    @IBAction func btnRomance(_ sender: Any) {
        navegarAGenero("Romance")
    }
    
    @IBAction func btnTerror(_ sender: Any) {
        navegarAGenero("Terror")
    }
}
