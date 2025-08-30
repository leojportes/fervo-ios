//
//  PlaceAnnotationView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 28/08/25.
//

import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    let location: FixedLocation
    var distance: String

    init(coordinate: CLLocationCoordinate2D, location: FixedLocation, distance: String) {
        self.coordinate = coordinate
        self.location = location
        self.distance = distance
    }
}

class PlaceAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "PlaceAnnotationView"

    private let distanceLabel = UILabel()
    private let imageView = UIImageView()

    override var annotation: MKAnnotation? {
        willSet {
            guard let placeAnnotation = newValue as? PlaceAnnotation else { return }
            setupUI()
            updateDistanceLabel(with: placeAnnotation.distance)
            loadImage(from: placeAnnotation.location.photoURL)
        }
    }

    private func setupUI() {
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        self.centerOffset = CGPoint(x: 0, y: -30)
        self.backgroundColor = .clear

        distanceLabel.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        distanceLabel.font = .systemFont(ofSize: 12, weight: .bold)
        distanceLabel.textColor = .white
        distanceLabel.textAlignment = .center
        distanceLabel.layer.cornerRadius = 4
        distanceLabel.clipsToBounds = true
        addSubview(distanceLabel)

        imageView.frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.circle.fill")
        addSubview(imageView)
    }

    func updateDistanceLabel(with text: String) {
        distanceLabel.text = text
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = image
                }
            } else {
                self.imageView.image = UIImage(systemName: "person.circle.fill")
            }
        }.resume()
    }
}
