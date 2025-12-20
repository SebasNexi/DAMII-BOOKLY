import UIKit

class BuscarController: UIViewController {

    private let gradient = CAGradientLayer()

        override func viewDidLoad() {
            super.viewDidLoad()

            gradient.colors = [
                UIColor.black.cgColor,
                UIColor(red: 45/255, green: 100/255, blue: 50/255, alpha: 1).cgColor
            ]
            
            gradient.locations = [0.0, 0.6]

            // Vertical: arriba → abajo
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)

            view.layer.insertSublayer(gradient, at: 0)
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradient.frame = view.bounds
        }

}
