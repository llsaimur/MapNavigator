//
//  ContentView.swift
//  MapNavigator
//
//  Created by Saimur Rashid on 2/17/26.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var camera: MapCameraPosition = .automatic
    @State private var zoomLevel: Double = 2000
    
    let lasalleCoords = CLLocationCoordinate2D(latitude: 45.4919, longitude: -73.5794)
    @State private var currentMapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 45.4919, longitude: -73.5794)
    
    @State private var searchText: String = ""
    @State private var destinationCoordinate: CLLocationCoordinate2D?
    @State private var selectedTransport: TransportType = .automobile
    @State private var route: MKRoute?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Map(position: $camera) {
                Marker("Collège LaSalle", coordinate: lasalleCoords)
                    .tint(.red)
                
                if let userLocation = locationManager.userLocation {
                    Marker("You", coordinate: userLocation)
                        .tint(.blue)
                }
                
                if let dest = destinationCoordinate {
                    Marker("Destination", coordinate: dest)
                        .tint(.green)
                }
                
                if let route = route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(.standard)
            .onMapCameraChange { context in
                // Part C: Track center for zooming
                currentMapCenter = context.camera.centerCoordinate
            }

            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: goToUserLocation) {
                            MapButtonIcon(systemName: "location.fill")
                        }
                        
                        Button(action: zoomIn) {
                            MapButtonIcon(systemName: "plus.magnifyingglass")
                        }

                        Button(action: zoomOut) {
                            MapButtonIcon(systemName: "minus.magnifyingglass")
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            
            if let route = route {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Distance: \(String(format: "%.2f", route.distance / 1000)) km")
                            Text("Time: \(Int(route.expectedTravelTime / 60)) mins")
                        }
                        .font(.system(.subheadline, design: .rounded).bold())
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                    }
                    .padding(.bottom, 180)
                    .padding(.horizontal)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                
                Picker("Transport", selection: $selectedTransport) {
                    ForEach(TransportType.allCases) { type in
                        Image(systemName: type.icon).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])
                .onChange(of: selectedTransport) { _ in
                    calculateRoute()
                }

                HStack {
                    TextField("Search for a destination", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    
                    Button(action: performSearch) {
                        Image(systemName: "magnifyingglass")
                            .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 8)
                }
            }
            .background(.thinMaterial)
        }
        .onAppear {
            camera = .camera(MapCamera(centerCoordinate: lasalleCoords, distance: zoomLevel))
        }
    }


    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: lasalleCoords, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let item = response?.mapItems.first else {
                self.errorMessage = "No results found."
                self.destinationCoordinate = nil
                self.route = nil
                return
            }
            self.errorMessage = nil
            self.destinationCoordinate = item.placemark.coordinate
            calculateRoute()
        }
    }

    private func calculateRoute() {
        guard let dest = destinationCoordinate else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: lasalleCoords))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest))
        request.transportType = selectedTransport.mkType
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                self.route = route
                // Part F: Fit camera to show entire route
                withAnimation {
                    camera = .rect(route.polyline.boundingMapRect)
                }
            } else {
                self.errorMessage = "Could not calculate route."
                self.route = nil
            }
        }
    }

    private func zoomIn() {
        withAnimation {
            zoomLevel *= 0.7
            camera = .camera(MapCamera(centerCoordinate: currentMapCenter, distance: zoomLevel))
        }
    }

    private func zoomOut() {
        withAnimation {
            zoomLevel *= 1.3
            camera = .camera(MapCamera(centerCoordinate: currentMapCenter, distance: zoomLevel))
        }
    }

    private func goToUserLocation() {
        if let userLocation = locationManager.userLocation {
            withAnimation {
                camera = .camera(MapCamera(centerCoordinate: userLocation, distance: 2000))
            }
        }
    }
}


#Preview {
    ContentView()
}
