import Foundation
import MapKit
import CoreLocation

struct Lugar: Identifiable {
    let id: String
    let nombre: String
    let coordenada: CLLocationCoordinate2D
    let amplitud: CLLocationDegrees

    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordenada,
            span: MKCoordinateSpan(
                latitudeDelta: amplitud,
                longitudeDelta: amplitud
            )
        )
    }

    // El primer centro es el utilizado en el PDF del profesor.
    // Los otros centros son aproximaciones para comparar diferentes regiones.
    static let predeterminados: [Lugar] = [
        Lugar(id: "imi", nombre: "Imí",
              coordenada: CLLocationCoordinate2D(latitude: 19.847707, longitude: -90.476276),
              amplitud: 0.05),
        Lugar(id: "campeche", nombre: "Centro de Campeche",
              coordenada: CLLocationCoordinate2D(latitude: 19.8439, longitude: -90.5360),
              amplitud: 0.015),
        Lugar(id: "cdmx", nombre: "Ciudad de México",
              coordenada: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
              amplitud: 0.04)
    ]
}
