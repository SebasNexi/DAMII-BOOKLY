import UIKit
import FirebaseFirestore

class LibroDAO: IMetodosLibro {
    
    // MARK: - Propiedades
    private let db = Firestore.firestore()
    private let nombreColeccion = "libros"
    
    // MARK: - 1. OBTENER TODOS (FIND ALL)
    func findAll() -> [libro] {
        var libros: [libro] = []
        let semaforo = DispatchSemaphore(value: 0)
        
        // Obtener todos los documentos
        db.collection(nombreColeccion).getDocuments { snapshot, error in
            
            if let error = error {
                print("❌ Error findAll: \(error.localizedDescription)")
                semaforo.signal()
                return
            }
            
            // Procesar documentos
            if let documentos = snapshot?.documents {
                for documento in documentos {
                    let datos = documento.data()
                    
                    // Crear objeto libro
                    let libro = libro(
                        codigo: datos["codigo"] as? Int ?? 0,
                        titulo: datos["titulo"] as? String ?? "Sin título",
                        autor: datos["autor"] as? String ?? "",
                        genero: datos["genero"] as? String ?? "",
                        descripcion: datos["descripcion"] as? String ?? "",
                        precio: datos["precio"] as? Double ?? 0.0,
                        imagen: datos["imagen"] as? String ?? ""
                    )
                    
                    libros.append(libro)
                }
                
                print("📚 Libros obtenidos: \(libros.count)")
            } else {
                print("ℹ️  No hay libros en la base de datos")
            }
            
            semaforo.signal()
        }
        
        _ = semaforo.wait(timeout: .now() + 10.0)
        return libros
    }
    
    // MARK: - 2. BUSCAR POR CÓDIGO (FIND BY ID)
    func findByCodigo(_ codigo: Int) -> libro? {
        var libroEncontrado: libro?
        let semaforo = DispatchSemaphore(value: 0)
        
        db.collection(nombreColeccion)
            .whereField("codigo", isEqualTo: codigo)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error findByCodigo: \(error.localizedDescription)")
                    semaforo.signal()
                    return
                }
                
                if let documento = snapshot?.documents.first {
                    let datos = documento.data()
                    
                    libroEncontrado = libro(
                        codigo: datos["codigo"] as? Int ?? 0,
                        titulo: datos["titulo"] as? String ?? "",
                        autor: datos["autor"] as? String ?? "",
                        genero: datos["genero"] as? String ?? "",
                        descripcion: datos["descripcion"] as? String ?? "",
                        precio: datos["precio"] as? Double ?? 0.0,
                        imagen: datos["imagen"] as? String ?? ""
                    )
                    
                    print("✅ Libro encontrado: \(libroEncontrado?.titulo ?? "Sin título")")
                } else {
                    print("ℹ️  No hay libro con código: \(codigo)")
                }
                
                semaforo.signal()
            }
        
        _ = semaforo.wait(timeout: .now() + 5.0)
        return libroEncontrado
    }
    
    // En LibroDAO.swift
    func findByGenero(_ genero: String) -> [libro] {
        var libros: [libro] = []
        let semaforo = DispatchSemaphore(value: 0)
        
        db.collection(nombreColeccion)
            .whereField("genero", isEqualTo: genero)  // Filtrar por género
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error findByGenero: \(error.localizedDescription)")
                    semaforo.signal()
                    return
                }
                
                if let documentos = snapshot?.documents {
                    for documento in documentos {
                        let datos = documento.data()
                        
                        let libroItem = libro(
                            codigo: datos["codigo"] as? Int ?? 0,
                            titulo: datos["titulo"] as? String ?? "Sin título",
                            autor: datos["autor"] as? String ?? "",
                            genero: datos["genero"] as? String ?? "",
                            descripcion: datos["descripcion"] as? String ?? "",
                            precio: datos["precio"] as? Double ?? 0.0,
                            imagen: datos["imagen"] as? String ?? ""
                        )
                        
                        libros.append(libroItem)
                    }
                    print("✅ findByGenero: \(libros.count) libros de \(genero)")
                }
                
                semaforo.signal()
            }
        
        _ = semaforo.wait(timeout: .now() + 10.0)
        return libros
    }
}
