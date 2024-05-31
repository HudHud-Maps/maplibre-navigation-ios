//
//  SceneDelegate.swift
//  Example
//
//  Created by Patrick Kladek on 16.05.24.
//

import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation
import MapLibre
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var viewController: NavigationViewController!
    var route: Route!
    
    let waypoints = [
        CLLocation(latitude: 52.032407, longitude: 5.580310),
        CLLocation(latitude: 52.04, longitude: 5.580310),
        CLLocation(latitude: 51.768686, longitude: 4.6827956)
    ].map { Waypoint(location: $0) }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
		
        self.window = UIWindow(windowScene: windowScene)
        
        // NOTE: You will need your own tile server, this uses a demo style that only shows country borders
        // this is not useful to evaluate the navigation, please change accordingly
        self.viewController = NavigationViewController(dayStyle: DayStyle(demoStyle: ()), nightStyle: NightStyle(demoStyle: ()))
        self.viewController.mapView?.tracksUserCourse = false
        self.viewController.mapView?.showsUserLocation = true
        self.viewController.mapView?.zoomLevel = 12
        self.viewController.mapView?.centerCoordinate = self.waypoints[0].coordinate
        self.viewController.delegate = self
        
        self.window?.rootViewController = self.viewController
        self.window?.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.startNavigation(for: Array(self.waypoints[0 ... 1]))
        }
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        self.viewController.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.viewController.view.layoutMarginsGuide.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: self.viewController.view.centerYAnchor),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
            button.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
}

extension SceneDelegate: NavigationViewControllerDelegate {
    func navigationViewControllerDidFinish(_ navigationViewController: NavigationViewController) {
        navigationViewController.endNavigation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            navigationViewController.startNavigation(with: self.route, locationManager: SimulatedLocationManager(route: self.route))
        }
    }
}

// MARK: - Private

private extension SceneDelegate {
    func startNavigation(for waypoints: [Waypoint]) {
        let options = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .automobileAvoidingTraffic)
        options.shapeFormat = .polyline6
        options.distanceMeasurementSystem = .metric
        options.attributeOptions = []
        
        Directions.shared.calculate(options) { _, routes, _ in
            guard let route = routes?.first else { return }
            
            self.route = route
            
            let simulatedLocationManager = SimulatedLocationManager(route: route)
            simulatedLocationManager.speedMultiplier = 2
            
            self.viewController.startNavigation(with: route, locationManager: simulatedLocationManager)
        }
    }
    
    @objc
    func buttonTapped() {
        guard let waypoint = self.waypoints.randomElement() else { return }
        
        func randomCLLocationDistance(min: CLLocationDistance, max: CLLocationDistance) -> CLLocationDistance {
            CLLocationDistance(arc4random_uniform(UInt32(max - min)) + UInt32(min))
        }

        let distance = randomCLLocationDistance(min: 10, max: 100_000)
        
        self.viewController.mapView?.camera = .init(lookingAtCenter: waypoint.coordinate,
                                                    acrossDistance: distance,
                                                    pitch: 0,
                                                    heading: 0)
    }
}
