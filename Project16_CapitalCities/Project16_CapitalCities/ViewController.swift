//
//  ViewController.swift
//  Project16_CapitalCities
//
//  Created by Blaine Dannheisser on 2/8/21.
//

import MapKit
import UIKit

// MARK: - PinColorType

enum PinColorType: String, CaseIterable {
    case red
    case black
    case green
    case blue
}

// MARK: - ViewController

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!

    var selectedWikipedia: String?
    var pageName: String?

    var pinColor: UIColor = .red

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Capital Cities"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(selectPinColor))

        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home of the 2012 Summer Olympics.", wikipediaPage: "en.wikipedia.org/wiki/London")

        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.", wikipediaPage: "en.wikipedia.org/wiki/Oslo")

        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the CIty of Lights.", wikipediaPage: "en.wikipedia.org/wiki/Paris")

        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.", wikipediaPage: "en.wikipedia.org/wiki/Rome")

        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself", wikipediaPage: "/en.wikipedia.org/wiki/Washington,_D.C.")

        mapView.addAnnotations([london, oslo, paris, rome, washington])

        let mapTypeButton = UIButton(type: .custom)
        mapTypeButton.translatesAutoresizingMaskIntoConstraints = false
        mapTypeButton.setImage(UIImage(named: "layerIcon"), for: .normal)
        mapTypeButton.clipsToBounds = true
        mapTypeButton.addTarget(self, action: #selector(mapTypeTapped), for: .touchUpInside)
        view.addSubview(mapTypeButton)

        NSLayoutConstraint.activate([
            mapTypeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15),
            mapTypeButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        ])
    }

    // MARK: Internal

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        let identifier = "Capital"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            let button = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = button
        } else {
            annotationView?.annotation = annotation
        }

        // TODO: google whether mapview has an equivalent to uitableviews reloaddata.

        annotationView?.pinTintColor = self.pinColor

        return annotationView
    }

    // Alernate way to dynamically add alert actions from all enum cases.  Note:enum must conform to `CaseIterable`.
    // PinColorType.allCases.forEach { colorType in
    //  ac.addAction(UIAlertAction(title: colorType.rawValue.capitalized,
//                              style: .default, handler: pickColor))
    //  }

    @objc func selectPinColor() {
        let ac = UIAlertController(title: "Change Pin Color", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: PinColorType.red.rawValue.capitalized, style: .default, handler: pickColor))
        ac.addAction(UIAlertAction(title: PinColorType.green.rawValue.capitalized, style: .default, handler: pickColor))
        ac.addAction(UIAlertAction(title: PinColorType.black.rawValue.capitalized, style: .default, handler: pickColor))
        ac.addAction(UIAlertAction(title: PinColorType.blue.rawValue.capitalized, style: .default, handler: pickColor))

        present(ac, animated: true)
    }

//    fileprivate func updatePinColor(for type: PinColorType) {
//        switch type {
//        case .red:
//            pinColor = UIColor.red
//        case .black:
//            pinColor = UIColor.black
//        case .green:
//            pinColor = UIColor.green
//        }
//    }

    func pickColor(action: UIAlertAction) {
        let allPinColors = PinColorType.allCases
        for color in allPinColors {
            if color.rawValue == action.title?.lowercased() {
                switch color {
                case .black:
                    pinColor = UIColor.black
                case .red:
                    pinColor = UIColor.red
                case .green:
                    pinColor = UIColor.green
                case .blue:
                    pinColor = UIColor.blue
                }
            }
        }
    }

        // Important and should replace the above.
        // TODO: Blaine, look up firstWhere in docs.

//        let matched = allPinColors.first(where: {
//            $0.rawValue == action.title?.lowercased()
//        }) ?? PinColorType.green
//
//        updatePinColor(for: matched)


    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        selectedWikipedia = capital.wikipediaPage
        pageName = capital.title
        let placeName = capital.title
        let placeInfo = capital.info

        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "More Information", style: .default, handler: openPage))
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    func openPage(action: UIAlertAction) {
        let vc = WebViewController()
        vc.cityWiki = selectedWikipedia
        vc.title = pageName

        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func mapTypeTapped(_ sender: UIButton) {
        UIButton.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {

            sender.transform = CGAffineTransform(scaleX: 3.5, y: 3.5)
            sender.transform = .identity

        }, completion: nil)

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
