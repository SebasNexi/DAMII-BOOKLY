import UIKit

protocol IMetodosLibrosCreados {
    func save(bean: librosCreados) -> Int
        func update(bean: librosCreados) -> Int  // Cambiar: usar librosCreados, no Entity
        func delete(codigo: Int) -> Int          // Cambiar: borrar por código
        func findAll() -> [librosCreados] 
}
