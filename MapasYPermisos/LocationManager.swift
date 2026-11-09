// Adaptación del ejemplo LocationManager.swift proporcionado por
// el Dr. José Aguilar: agrega estados de autorización, control de
// inicio/detención y manejo de errores.
import Foundation
import Combine
import MapKit
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var deseaActualizar = false

    @Published private(set) var region = Lugar.predeterminados[0].region
    @Published private(set) var ultimaUbicacion: CLLocation?
    @Published private(set) var autorizacion: CLAuthorizationStatus = .notDetermined
    @Published private(set) var actualizando = false
    @Published private(set) var mensaje = "Pulsa Mi ubicación para solicitar permiso."
    @Published private(set) var cantidadActualizaciones = 0

    var estadoPermiso: String {
        switch autorizacion {
        case .notDetermined: return "Sin solicitar"
        case .authorizedWhenInUse, .authorizedAlways: return "Permitido"
        case .denied: return "Denegado"
        case .restricted: return "Restringido"
        @unknown default: return "Desconocido"
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        autorizacion = manager.authorizationStatus
    }

    func solicitarUbicacion() {
        deseaActualizar = true
        comprobarAutorizacion()
    }

    func detener() {
        deseaActualizar = false
        manager.stopUpdatingLocation()
        actualizando = false
        mensaje = "Seguimiento detenido. Puedes explorar los lugares."
    }

    private func comprobarAutorizacion() {
        autorizacion = manager.authorizationStatus
        switch autorizacion {
        case .notDetermined:
            if deseaActualizar {
                mensaje = "Esperando tu elección en el permiso de ubicación…"
                manager.requestWhenInUseAuthorization()
            }
        case .authorizedWhenInUse, .authorizedAlways:
            guard deseaActualizar else { return }
            if !actualizando {
                actualizando = true
                mensaje = "Esperando coordenadas del dispositivo…"
                manager.startUpdatingLocation()
            }
        case .denied:
            manager.stopUpdatingLocation()
            actualizando = false
            ultimaUbicacion = nil
            mensaje = "Permiso denegado. Puedes habilitarlo desde Ajustes y volver a pulsar Mi ubicación."
        case .restricted:
            manager.stopUpdatingLocation()
            actualizando = false
            ultimaUbicacion = nil
            mensaje = "La ubicación está restringida en este dispositivo."
        @unknown default:
            actualizando = false
            mensaje = "El sistema devolvió un estado de autorización desconocido."
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        comprobarAutorizacion()
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard deseaActualizar,
              let location = locations.last,
              location.horizontalAccuracy >= 0,
              CLLocationCoordinate2DIsValid(location.coordinate) else { return }

        cantidadActualizaciones += 1
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        mensaje = "Ubicación recibida y actualizada."
        // Publicar al final permite que la vista lea la región ya actualizada.
        ultimaUbicacion = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
            mensaje = "Aún no hay ubicación disponible. Configura una posición en el simulador o en Appetize."
        } else if let clError = error as? CLError, clError.code == .denied {
            comprobarAutorizacion()
        } else {
            mensaje = "No se pudo obtener la ubicación: \(error.localizedDescription)"
        }
    }
}
