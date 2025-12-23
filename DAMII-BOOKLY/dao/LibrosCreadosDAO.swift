import UIKit
import FirebaseFirestore

class LibrosCreadosDAO: IMetodosLibrosCreados {
    
    // MARK: - Propiedades
    private let db = Firestore.firestore()
    private let nombreColeccion = "librosCreados"
    
    // MARK: - 1. GUARDAR (CREATE)
    func save(bean: librosCreados) -> Int {
        var salida = -1
        let semaforo = DispatchSemaphore(value: 0)
        
        // Convertir struct a diccionario para Firebase
        let datos: [String: Any] = [
            "codigo": bean.codigo,
            "titulo": bean.titulo,
            "genero": bean.genero,
            "descripcion": bean.descripcion,
            "imagen": bean.imagen,
            "fechaCreacion": FieldValue.serverTimestamp()
        ]
        
        // Guardar en Firebase
        db.collection(nombreColeccion).addDocument(data: datos) { error in
            if let error = error {
                print("❌ Error save: \(error.localizedDescription)")
                salida = -1
            } else {
                print("✅ Libro guardado: \(bean.titulo)")
                salida = 1
            }
            semaforo.signal()
        }
        
        // Esperar respuesta (máximo 10 segundos)
        _ = semaforo.wait(timeout: .now() + 10.0)
        return salida
    }
    
    // MARK: - 2. ACTUALIZAR (UPDATE)
    func update(bean: librosCreados) -> Int {
        var salida = -1
        let semaforo = DispatchSemaphore(value: 0)
        
        // Buscar documento por código
        db.collection(nombreColeccion)
            .whereField("codigo", isEqualTo: bean.codigo)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error update/buscar: \(error.localizedDescription)")
                    semaforo.signal()
                    return
                }
                
                guard let documento = snapshot?.documents.first else {
                    print("❌ No existe libro con código: \(bean.codigo)")
                    semaforo.signal()
                    return
                }
                
                // Preparar datos actualizados
                let datosActualizados: [String: Any] = [
                    "titulo": bean.titulo,
                    "genero": bean.genero,
                    "descripcion": bean.descripcion,
                    "imagen": bean.imagen
                ]
                
                // Actualizar documento
                let documentoId = documento.documentID
                self.db.collection(self.nombreColeccion)
                    .document(documentoId)
                    .updateData(datosActualizados) { error in
                        if let error = error {
                            print("❌ Error update/actualizar: \(error.localizedDescription)")
                            salida = -1
                        } else {
                            print("✅ Libro actualizado: \(bean.titulo)")
                            salida = 1
                        }
                        semaforo.signal()
                    }
            }
        
        _ = semaforo.wait(timeout: .now() + 10.0)
        return salida
    }
    
    // MARK: - 3. ELIMINAR (DELETE)
    func delete(codigo: Int) -> Int {
        var salida = -1
        let semaforo = DispatchSemaphore(value: 0)
        
        // Buscar documento por código
        db.collection(nombreColeccion)
            .whereField("codigo", isEqualTo: codigo)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error delete/buscar: \(error.localizedDescription)")
                    semaforo.signal()
                    return
                }
                
                guard let documento = snapshot?.documents.first else {
                    print("❌ No existe libro con código: \(codigo)")
                    semaforo.signal()
                    return
                }
                
                // Eliminar documento
                let documentoId = documento.documentID
                self.db.collection(self.nombreColeccion)
                    .document(documentoId)
                    .delete { error in
                        if let error = error {
                            print("❌ Error delete/eliminar: \(error.localizedDescription)")
                            salida = -1
                        } else {
                            print("✅ Libro eliminado, código: \(codigo)")
                            salida = 1
                        }
                        semaforo.signal()
                    }
            }
        
        _ = semaforo.wait(timeout: .now() + 10.0)
        return salida
    }
    
    // MARK: - 4. OBTENER TODOS (FIND ALL)
    func findAll() -> [librosCreados] {
        var libros: [librosCreados] = []
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
                    
                    // Crear objeto librosCreados
                    let libro = librosCreados(
                        codigo: datos["codigo"] as? Int ?? 0,
                        titulo: datos["titulo"] as? String ?? "Sin título",
                        genero: datos["genero"] as? String ?? "",
                        descripcion: datos["descripcion"] as? String ?? "",
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
    
    // MARK: - MÉTODO ADICIONAL ÚTIL
    func findByCodigo(_ codigo: Int) -> librosCreados? {
        var libroEncontrado: librosCreados?
        let semaforo = DispatchSemaphore(value: 0)
        
        db.collection(nombreColeccion)
            .whereField("codigo", isEqualTo: codigo)
            .getDocuments { snapshot, error in
                
                if let documento = snapshot?.documents.first {
                    let datos = documento.data()
                    
                    libroEncontrado = librosCreados(
                        codigo: datos["codigo"] as? Int ?? 0,
                        titulo: datos["titulo"] as? String ?? "",
                        genero: datos["genero"] as? String ?? "",
                        descripcion: datos["descripcion"] as? String ?? "",
                        imagen: datos["imagen"] as? String ?? ""
                    )
                }
                
                semaforo.signal()
            }
        
        _ = semaforo.wait(timeout: .now() + 5.0)
        return libroEncontrado
    }
}
