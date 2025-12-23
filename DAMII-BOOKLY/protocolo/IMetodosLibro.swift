import UIKit

protocol IMetodosLibro{
    func findAll() -> [libro]
    func findByCodigo(_ codigo: Int) -> libro?
}
