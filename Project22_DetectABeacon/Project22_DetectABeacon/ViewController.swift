//
//  ViewController.swift
//  Project22_DetectABeacon
//
//  Created by Blaine Dannheisser on 2/23/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var distanceReading: UILabel!

    @IBOutlet var beaconName: UILabel!
    @IBOutlet var circleView: UIView!

    var locationManager: CLLocationManager?
    var beaconFound = true
    var beaconUUID: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        beaconName.text = "Unidentified"

        circleView.layer.cornerRadius = 128
        circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

        view.backgroundColor = .gray
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }

    func startScanning() {
        beaconRegion(uuid:"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", major: 417, minor: 984, name: "Kitchen")
//        beaconRegion(uuid:"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 417, minor: 984, name: "Living Room")
//        beaconRegion(uuid:"52414449-5553-5457-4F524B5334F", major: 417, minor: 984, name: "Bedroom")
    }

    func beaconRegion(uuid: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, name: String){
        let uuid = UUID(uuidString: uuid)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: CLBeaconIdentityConstraint(uuid: uuid!, major: major, minor: minor), identifier: name)
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid!, major: major, minor: minor))
    }

    func update(distance: CLProximity, name: String) {
        UIView.animate(withDuration: 1) { [weak self] in
            self?.beaconName.text = name
            switch distance {
            case .far:
                self?.view.backgroundColor = UIColor.blue
                self?.circleView.backgroundColor = UIColor.yellow
                self?.distanceReading.text = "FAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)

            case .near:
                self?.view.backgroundColor = UIColor.orange
                self?.circleView.backgroundColor = UIColor.blue
                self?.distanceReading.text = "NEAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            case .immediate:
                self?.view.backgroundColor = UIColor.red
                self?.circleView.backgroundColor = UIColor.white
                self?.distanceReading.text = "RIGHT HERE"
                self?.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

            default:
                self?.view.backgroundColor = UIColor.gray
                self?.circleView.backgroundColor = UIColor.red
                self?.distanceReading.text = "UNKNOWN"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {

            if beaconUUID == nil {
                beaconUUID = region.uuid
            }
            guard beaconUUID == region.uuid else { return }
            update(distance: beacon.proximity, name: region.identifier)
            beaconAlert()
        } else {
            guard beaconUUID == region.uuid else { return }
            beaconUUID = nil
            update(distance: .unknown, name: region.identifier)
        }
    }

    func beaconAlert() {
        if beaconFound {
            beaconFound = false

            let ac = UIAlertController(title: "Beacon Detected", message: "A Beacon Has Detected. Follow the Screen to  Location", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true)
        }
    }
}

