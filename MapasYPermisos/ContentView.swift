import SwiftUI
import Combine
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var seleccion = Lugar.predeterminados[0].id
    @State private var region = Lugar.predeterminados[0].region
    @State private var posicion: MapCameraPosition = .region(Lugar.predeterminados[0].region)
    @State private var siguiendo = false
    @State private var tipoMapa = 0

    private var lugarSeleccionado: Lugar {
        Lugar.predeterminados.first(where: { $0.id == seleccion }) ?? Lugar.predeterminados[0]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Lugar", selection: $seleccion) {
                        ForEach(Lugar.predeterminados) { lugar in
                            Text(lugar.nombre).tag(lugar.id)
                        }
                    }
                    .pickerStyle(.menu)

                    HStack {
                        Button("Ver lugar", action: mostrarLugarSeleccionado)
                        Spacer()
                        Button(action: mostrarSiguiente) {
                            Label("Siguiente", systemImage: "arrow.right")
                        }
                    }
                    Picker("Tipo de mapa", selection: $tipoMapa) {
                        Text("Normal").tag(0)
                        Text("Satélite").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                Divider()

                // Map moderno para iOS 17/macOS 14. El centro y el span
                // siguen representados por MKCoordinateRegion como en el PDF.
                Map(position: $posicion) {
                    ForEach(Lugar.predeterminados) { lugar in
                        Marker(lugar.nombre, coordinate: lugar.coordenada)
                            .tint(.orange)
                    }
                    UserAnnotation()
                }
                .mapStyle(tipoMapa == 0 ? .standard : .imagery)
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    region = context.region
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 230)

                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Ubicación", systemImage: "location.fill")
                            .font(.headline)
                        Spacer()
                        Text(locationManager.estadoPermiso)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text(locationManager.mensaje)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)

                    if let location = locationManager.ultimaUbicacion {
                        Text("Lat: \(location.coordinate.latitude, specifier: "%.6f") · Lon: \(location.coordinate.longitude, specifier: "%.6f")")
                            .font(.caption).monospacedDigit()
                        Text("Precisión: ±\(location.horizontalAccuracy, specifier: "%.0f") m · Actualizaciones: \(locationManager.cantidadActualizaciones)")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("Última recepción: \(location.timestamp.formatted(date: .omitted, time: .standard))")
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    HStack {
                        Button(action: mostrarMiUbicacion) {
                            Label("Mi ubicación", systemImage: "location.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                        if siguiendo {
                            Button("Detener") {
                                siguiendo = false
                                locationManager.detener()
                            }
                        }
                    }
                    #if targetEnvironment(simulator)
                    Text("Simulador: la posición recibida es simulada.")
                        .font(.caption2).foregroundStyle(.secondary)
                    #endif
                }
                .padding()
            }
            .navigationTitle("Mapas y permisos")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onChange(of: seleccion) { _, _ in
                mostrarLugarSeleccionado()
            }
            .onReceive(locationManager.$ultimaUbicacion.compactMap { $0 }) { _ in
                guard siguiendo else { return }
                moverMapa(a: locationManager.region)
            }
            .onDisappear {
                siguiendo = false
                locationManager.detener()
            }
        }
    }

    private func moverMapa(a nuevaRegion: MKCoordinateRegion) {
        region = nuevaRegion
        withAnimation(.easeInOut(duration: 0.6)) {
            posicion = .region(nuevaRegion)
        }
    }

    private func mostrarLugarSeleccionado() {
        siguiendo = false
        locationManager.detener()
        moverMapa(a: lugarSeleccionado.region)
    }

    private func mostrarSiguiente() {
        let lugares = Lugar.predeterminados
        let actual = lugares.firstIndex(where: { $0.id == seleccion }) ?? 0
        seleccion = lugares[(actual + 1) % lugares.count].id
    }

    private func mostrarMiUbicacion() {
        siguiendo = true
        locationManager.solicitarUbicacion()
        if locationManager.ultimaUbicacion != nil {
            moverMapa(a: locationManager.region)
        }
    }
}
