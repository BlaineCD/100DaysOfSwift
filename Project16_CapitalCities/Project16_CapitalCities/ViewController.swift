//
//  ViewController.swift
//  Project16_CapitalCities
//
//  Created by Blaine Dannheisser on 2/8/21.
//

import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home of the 2012 Summer Olympics.")

        let oslo = Capital(title: "Oslow", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")

        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the CIty of Lights.")

        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")

        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself")

        mapView.addAnnotations([london, oslo, paris, rome, washington])

        let mapTypeButton = UIButton(type: .custom)
        mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
        mapTypeButton.setImage(UIImage(systemName: "map.fill"), for: .normal)
        mapTypeButton.addTarget(self, action: #selector(mapTypeTapped), for: .touchUpInside)
        view.addSubview(mapTypeButton)

        NSLayoutConstraint.activate([
            mapTypeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            mapTypeButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1 if annotation isn't from a capital city, return nil so iOS uses a default view
        guard annotation is Capital else { return nil }
        // 2 define reuse identifier
        let identifier = "Capital"
        // 3 Try to dequeue an annotation view from the maps view's pool of unused views
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView


        if annotationView == nil {
            // 4 If not able to find a reusable view, create a new one using MKPin... and set its canShow.. property to true to trigger popup with city name.
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.pinTintColor = UIColor(red: 0.2784, green: 0.3294, blue: 0, alpha: 1.0)
            // 5 small blue "i" symbol
            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            //6 If able to reuse a view, update that view to use a different annotation
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let placeName = capital.title
        let placeInfo = capital.info

        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true )
    }

    @objc func mapTypeTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Select Map View", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: setCustomMapView))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: setCustomMapView))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: setCustomMapView))
        ac.addAction(UIAlertAction(title: "Muted", style: .default, handler: setCustomMapView))
        ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default, handler: setCustomMapView))
        ac.addAction(UIAlertAction(title: "Standard Flyover", style: .default, handler: setCustomMapView))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    func setCustomMapView(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        switch actionTitle {
        case "Standard":
            mapView.mapType = MKMapType.standard
        case "Satellite":
            mapView.mapType = MKMapType.satellite
        case "Hybrid":
            mapView.mapType = MKMapType.hybrid
        case "Muted":
            mapView.mapType = MKMapType.mutedStandard
        case "Satellite Flyover":
            mapView.mapType = MKMapType.satelliteFlyover
        case "Standard Flyover":
            mapView.mapType = MKMapType.hybridFlyover
        default:
            mapView.mapType = MKMapType.standard
        }
    }
}


