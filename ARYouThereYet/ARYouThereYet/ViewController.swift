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
import AlamofireImage
import Alamofire

class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    let locationManager = CLLocationManager()
    var annotationManager: AnnotationManager!
    fileprivate var startedLoadingPOIs = false
    var listOfAnnotations: [Annotation] = []

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
        //let scene = SCNscene(named: "art.scnassets/ship.scn")!
        
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
            
            if let touchedNode = node as? customNode {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nav = storyBoard.instantiateViewController(withIdentifier: "NavViewController") as! NavViewController
                nav.currentLocation = locationManager.location!.coordinate
                let destinationLocation = CLLocationCoordinate2D(latitude: (touchedNode.annotation?.latitude)!, longitude: (touchedNode.annotation?.longitude)!)
                nav.destinationLocationCustom = destinationLocation
                self.present(nav, animated: true, completion: nil)
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
            result = response*/
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
                                let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                                let reference = placeDict.object(forKey: "reference") as! String
                                let name = placeDict.object(forKey: "name") as! String
                                let address = placeDict.object(forKey: "vicinity") as! String
                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                let rating = placeDict.object(forKey: "rating") as? Double ?? 0.0
                                let iconURL = placeDict.object(forKey: "icon") as! String
                                let placeID = placeDict.object(forKey: "id") as! String
                                
                                DispatchQueue.main.async {
                                    Alamofire.request(URL(string: iconURL)!, method: .get).responseImage { response in
                                        if let icon = response.result.value {
                                            // print("\(name) has icon")
                                            let annotation = Annotation(location: location, calloutImage: nil, name: name, reference: reference, address: address, latitude: latitude, longitude: longitude, distance: (self.locationManager.location?.distance(from: location))!, rating: rating, icon: icon, id: placeID)
                                            self.listOfAnnotations.append(annotation)
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
    }
}

extension ViewController: AnnotationManagerDelegate {
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            // Tracking is sufficient to begin experience
            // allowARInteractions()
            print("\n")
        default:
            break
        }
    }
    
    func node(for annotation: Annotation) -> SCNNode? {
<<<<<<< HEAD
//        let nameNode = SCNText(string: annotation.name, extrusionDepth: 0.0)
//        nameNode.font = UIFont(name: "HelveticaNeue", size: 3.0)
//        let mainNode = customNode(geometry: nameNode, location: annotation.location.coordinate)
        
        /*
         Parameters:
         Z-Depth: Placing the annotation in the field. (Float)
         Y-Coordinate: Placing the annotation at a height to minimize overlapping. (Float)
         */
        
        //Create annotations on the street.
        let nameOfPlace = SCNText(string: annotation.name, extrusionDepth: 0.1)        //Replace string with incoming string value for every node.
        nameOfPlace.font = UIFont(name: "Futura", size: 0.3)        //Fontsize can be played around with. But 0.3 seems fine.
        nameOfPlace.firstMaterial!.diffuse.contents = UIColor.white
        nameOfPlace.firstMaterial!.specular.contents = UIColor.white
        
        
        let max = nameOfPlace.boundingBox.max       //fetching min and max vounds of of the created geomtric entity.
        let min = nameOfPlace.boundingBox.min
        
        
        //Create Another text entity for distance.
        let compString = String(annotation.distance) + "mts"
        let dist = SCNText(string: compString, extrusionDepth: 0.1)
        dist.font = UIFont.init(name: "Futura", size: 0.15)
        dist.firstMaterial!.diffuse.contents = UIColor.white
        
        //Create holding geometry and corresponding node for icon.
        let icon = SCNPlane(width: 0.5, height: 0.5)
        let iconMaterial = SCNMaterial()
        iconMaterial.diffuse.contents = annotation.icon
        icon.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        icon.materials = [iconMaterial]
        let widthOfIcon = icon.boundingBox.max.x - icon.boundingBox.min.x
        
        
        //Bounding values for the place WRT to the Text.
        let annotX = (max.x - min.x + widthOfIcon) + 0.5
        let annotY = (max.y - min.y) + 0.5
        
        let annotSmall = SCNPlane(width: CGFloat(annotX), height: CGFloat(annotY))      //Create SCNPlane with the width matching the textNode.
        annotSmall.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        annotSmall.cornerRadius = 0.5
        let annotNode = SCNNode(geometry: annotSmall)   //Create Node
        
        
        let posMin = annotSmall.boundingBox.min
        
        //Create nodes for all entities.
        let labelNode = customNode(geometry: nameOfPlace, location: annotation.location.coordinate)
        let distNode = customNode(geometry: dist, location: annotation.location.coordinate)
        let iconNode = customNode(geometry: icon, location: annotation.location.coordinate)
        
        labelNode.position = SCNVector3(posMin.x + widthOfIcon + 0.2, -1.1, posMin.z)
        distNode.position = SCNVector3(posMin.x + widthOfIcon + 0.2, -1.3, posMin.z)
        iconNode.position = SCNVector3((posMin.x + widthOfIcon/2) + 0.1, 0, posMin.z + 0.1)
        
        //Make all nodes children ofa parent SCNPlane.
        annotNode.addChildNode(labelNode)
        annotNode.addChildNode(distNode)
        annotNode.addChildNode(iconNode)
        
        return annotNode
    }
}

class customNode: SCNNode {
    public var annotation: Annotation?
    init(geometry: SCNGeometry, annotation: Annotation) {
        super.init()
        self.geometry = geometry
        self.annotation = annotation
    }
    /* Xcode required this */
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
