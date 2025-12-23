import UIKit
import FirebaseFirestore

class PagoDAO: IMetodosPago {
    // MARK: - Propiedades
    private let db = Firestore.firestore()
    private let nombreColeccion = "pagos"  // Cambia si tu colección tiene otro nombre
    
    // MARK: - OBTENER TODOS (FIND ALL)
    func findAll() -> [pago] {
        var pagos: [pago] = []
        let semaforo = DispatchSemaphore(value: 0)
        
        // Obtener todos los documentos
        db.collection(nombreColeccion).getDocuments { snapshot, error in
            
            if let error = error {
                print("❌ Error findAll pagos: \(error.localizedDescription)")
                semaforo.signal()
                return
            }
            
            // Procesar documentos
            if let documentos = snapshot?.documents {
                for documento in documentos {
                    let datos = documento.data()
                    
                    // Crear objeto pago
                    let pagoItem = pago(
                        codigo: datos["codigo"] as? Int ?? 0,
                        titulo: datos["titulo"] as? String ?? "Sin título",
                        genero: datos["genero"] as? String ?? "",
                        autor: datos["autor"] as? String ?? "",
                        precio: datos["precio"] as? Double ?? 0.0,
                        imagen: datos["imagen"] as? String ?? ""
                    )
                    
                    pagos.append(pagoItem)
                }
                
                print("💰 Pagos obtenidos: \(pagos.count)")
            } else {
                print("ℹ️  No hay pagos en la base de datos")
            }
            
            semaforo.signal()
        }
        
        _ = semaforo.wait(timeout: .now() + 10.0)
        return pagos
    }
    
    // MARK: - MÉTODO ADICIONAL ÚTIL (si lo necesitas después)
    func findByCodigo(_ codigo: Int) -> pago? {
        var pagoEncontrado: pago?
        let semaforo = DispatchSemaphore(value: 0)
        
        db.collection(nombreColeccion)
            .whereField("codigo", isEqualTo: codigo)
            .getDocuments { snapshot, error in
                
                if let documento = snapshot?.documents.first {
                    let datos = documento.data()
                    
                    pagoEncontrado = pago(
                        codigo: datos["codigo"] as? Int ?? 0,
                        titulo: datos["titulo"] as? String ?? "",
                        genero: datos["genero"] as? String ?? "",
                        autor: datos["autor"] as? String ?? "",
                        precio: datos["precio"] as? Double ?? 0.0,
                        imagen: datos["imagen"] as? String ?? ""
                    )
                    
                    print("✅ Pago encontrado: \(pagoEncontrado?.titulo ?? "Sin título")")
                }
                
                semaforo.signal()
            }
        
        _ = semaforo.wait(timeout: .now() + 5.0)
        return pagoEncontrado
    }
}
