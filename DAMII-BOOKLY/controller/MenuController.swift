import UIKit

class MenuController: UIViewController,
                      UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let gradient = CAGradientLayer()

    let libros = [
        "LibroCiencia2", "LibroFantasia4", "LibroCiencia3",
        "LibroFiccion4", "LibroRomance3", "LibroRomance5"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor(red: 45/255, green: 100/255, blue: 50/255, alpha: 1).cgColor
        ]

        gradient.locations = [0.0, 0.7]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)

        view.layer.insertSublayer(gradient, at: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return libros.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "LibroCell",
            for: indexPath
        )

        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: libros[indexPath.item])

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding: CGFloat = 16
        let availableWidth = collectionView.frame.width - padding
        let width = availableWidth / 3

        return CGSize(width: width, height: width * 1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "DescripcionController"
        ) as! DescripcionController

        vc.imagenLibro = libros[indexPath.item]

        present(vc, animated: true)
    }

}
