//
//  UserAnnotationView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/08/25.
//

import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    let imageURL: URL?
    let userModel: UserModel

    init(coordinate: CLLocationCoordinate2D, imageURL: URL?, userModel: UserModel) {
        self.coordinate = coordinate
        self.imageURL = imageURL
        self.userModel = userModel
    }
}

class UserAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "UserAnnotationView"

    override var annotation: MKAnnotation? {
        willSet {
            guard let userAnnotation = newValue as? UserAnnotation else { return }

            frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            layer.cornerRadius = 20
            clipsToBounds = true
            backgroundColor = .clear
            layer.borderWidth = 0.6
            layer.borderColor = UIColor.white.cgColor

            // Carrega imagem da URL
            if let url = userAnnotation.imageURL {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.image = image.resized(to: CGSize(width: 40, height: 40))
                            self.layer.cornerRadius = 20
                            self.clipsToBounds = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.image = UIImage(systemName: "person.circle.fill")
                        }
                    }
                }.resume()
            } else {
                image = UIImage(systemName: "person.circle.fill")
            }
        }
    }
}
