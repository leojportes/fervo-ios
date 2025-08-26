//
//  CLLocationCoordinate2D+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/08/25.
//

import CoreLocation

extension CLLocationCoordinate2D {
    /// Retorna uma nova coordenada deslocada em metros no eixo X/Y
    func offsetBy(latMeters: Double, lonMeters: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6378137.0

        let newLat = self.latitude + (latMeters / earthRadius) * (180.0 / .pi)
        let newLon = self.longitude + (lonMeters / (earthRadius * cos(.pi * self.latitude / 180.0))) * (180.0 / .pi)

        return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
    }
}
