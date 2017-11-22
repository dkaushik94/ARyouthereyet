//
//  ViewController.swift
//  ARYouThereYet
//
//  Created by Debojit Kaushik  on 11/7/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapKit
import MapboxARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    let locationManager = CLLocationManager()
    var annotationManager: AnnotationManager!
    fileprivate var startedLoadingPOIs = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Config CLLocationManager object
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        // Create the annotation manager instance and give it an ARSCNView
        annotationManager = AnnotationManager(sceneView: sceneView)
        annotationManager.delegate = self
        annotationManager.originLocation = locationManager.location
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action:  #selector(tapped))
        sceneView.gestureRecognizers = [tapRecognizer]
        
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0] as SCNHitTestResult
            let node = result.node
            
            if let touchedNode = node as? SCNNode {
                print("Touched the location node")
            }
        }
    
    }
    
    @IBAction func showMenu(_ sender: Any) {
        let mainMenuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainMenuVC") as! MainMenuViewController
        
        self.addChildViewController(mainMenuVC)
        mainMenuVC.view.frame = self.view.frame
        self.view.addSubview(mainMenuVC.view)
        mainMenuVC.didMove(toParentViewController: self)

    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // locationManager.requestLocation()
        // let currentLocation = locationManager.location!
        // let identityLocation = matrix_identity_float4x4
        
        /*// MK-MapKit
        var result = MKLocalSearchResponse()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "coffee"
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            result = response
            
            for i in result.mapItems {
                let endLocation = CLLocation(latitude: i.placemark.coordinate.latitude, longitude: i.placemark.coordinate.longitude)
                let holder = MatrixHelper.transformMatrix(for: identityLocation, originLocation: currentLocation, location: endLocation)
                let geometry = SCNSphere(radius: 0.5)
                geometry.firstMaterial?.diffuse.contents = UIColor.blue
                let sphereNode = SCNNode(geometry: geometry)
                let testAnchor = ARAnchor(transform: holder)
                sphereNode.transform = SCNMatrix4.init(testAnchor.transform)
                sphereNode.position = SCNVector3Make(holder.columns.3.x, holder.columns.3.y, holder.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                self.sceneView.session.add(anchor: testAnchor)
                print("\(i.placemark)\n")
            }
        }*/
        
        /*for i in result.mapItems {
            // let endLocation = CLLocation(latitude: 41.871876, longitude: -87.650500)
            let endLocation = CLLocation(latitude: i.placemark.coordinate.latitude, longitude: i.placemark.coordinate.longitude)
            let holder = MatrixHelper.transformMatrix(for: identityLocation, originLocation: currentLocation, location: endLocation)
            let geometry = SCNSphere(radius: 0.5)
            geometry.firstMaterial?.diffuse.contents = UIColor.blue
            let sphereNode = SCNNode(geometry: geometry)
            let testAnchor = ARAnchor(transform: holder)
            sphereNode.transform = SCNMatrix4.init(testAnchor.transform)
            sphereNode.position = SCNVector3Make(holder.columns.3.x, holder.columns.3.y, holder.columns.3.z)
            sceneView.scene.rootNode.addChildNode(sphereNode)
            sceneView.session.add(anchor: testAnchor)
        }*/
        
        // print(matchingItems)
        
        
        // 41.870820, -87.650454
        
        /*let endLocation = CLLocation(latitude: 41.871876, longitude: -87.650500)
        let holder = MatrixHelper.transformMatrix(for: identityLocation, originLocation: currentLocation, location: endLocation)
        let geometry = SCNSphere(radius: 0.5)
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let sphereNode = SCNNode(geometry: geometry)
        
        let testAnchor = ARAnchor(transform: holder)
        sphereNode.transform = SCNMatrix4.init(testAnchor.transform)
        sphereNode.position = SCNVector3Make(holder.columns.3.x, holder.columns.3.y, holder.columns.3.z)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        sceneView.session.add(anchor: testAnchor)*/
        
        // sphereNode.position = SCNVector3Make(holder.columns.3.x, 0, holder.columns.3.z)
        // sphereNode.position = SCNVector3(sceneView.pointOfView!.simdWorldFront.x + holder.columns.3.x, sceneView.pointOfView!.simdWorldFront.y + holder.columns.3.y, sceneView.pointOfView!.simdWorldFront.z + holder.columns.3.z)
        

        //locationLabel.text = String(testAnchor.transform.columns.3.x)
        
        // print("TestAnchor: %s", testAnchor.transform)
        // print("SphereNode: %s", sphereNode.transform)
        
        // locationLabel.text = "\(testAnchor.transform.columns.3.x, testAnchor.transform.columns.3.y, testAnchor.transform.columns.3.z)"
    }
}

extension ViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let location = locations.last!
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                // let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                // let region = MKCoordinateRegion(center: location.coordinate, span: span)
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true
                    let loader = PlacesLoader()
                    loader.loadPOIS(location: location, radius: 500) { placesDict, error in
                        if let dict = placesDict {
                            guard let placesArray = dict.object(forKey: "results") as? [NSDictionary] else { return }
                            for placeDict in placesArray {
                                let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                                 let longtiude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                                 let reference = placeDict.object(forKey: "reference") as! String
                                 let name = placeDict.object(forKey: "name") as! String
                                 let address = placeDict.object(forKey: "vicinity") as! String
                                
                                 let location = CLLocation(latitude: latitude, longitude: longtiude)
                                 // print("Name: \(name), Location: \(location)")
                                 DispatchQueue.main.async {
                                    let annotation = Annotation(location: location, calloutImage: nil, name: name)
                                 self.annotationManager.addAnnotation(annotation: annotation)
                                 }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}

extension ViewController: AnnotationManagerDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            // Tracking is sufficient to begin experience
            // allowARInteractions()
            print("trackingState = normal")
        default:
            break
        }
    }
    
    func node(for annotation: Annotation) -> SCNNode? {
        let nameNode = SCNText(string: annotation.name, extrusionDepth: 0.0)
        nameNode.font = UIFont(name: "HelveticaNeue", size: 3.0)
        let mainNode = SCNNode(geometry: nameNode)
        return mainNode
    }
}
