import UIKit

class DescripcionController: UIViewController {

    var imagenLibro: String?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet weak var precioLabel: UILabel!
    @IBOutlet weak var descripcionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imagen = imagenLibro {
            imageView.image = UIImage(named: imagen)
        }

        // luego pondremos nombre, autor, precio
    }
}
