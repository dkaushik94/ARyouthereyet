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
import GooglePlaces
import AVFoundation
import CircleMenu
import CoreData

class ViewController: UIViewController, ARSCNViewDelegate, CircleMenuDelegate, delegateForFilterView {

    @IBOutlet weak var menuButton: CircleMenu!
    @IBOutlet weak var cameraStateLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    let locationManager = CLLocationManager()
    var annotationManager: AnnotationManager!
    fileprivate var startedLoadingPOIs = false
    var listOfAnnotations: [Annotation] = []
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var timer = Timer()
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!

    var distanceRadius: Float? = 200

    var filters: [String]?


    let items: [(icon: String, color: UIColor)] = [
        ("icon_home", UIColor(red:0.19, green:0.57, blue:1, alpha:1)),
        ("icon_search", UIColor(red:0.22, green:0.74, blue:0, alpha:1)),
        ("nearby-btn", UIColor(red:0.96, green:0.23, blue:0.21, alpha:1)),
        ("starFilled",UIColor.clear)]


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filterView = segue.destination as? FilterMenuViewController {
            filterView.delegate = self
        }
    }


    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color

        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)

        // set highlited image
        let highlightedImage  = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
    }


    //Delegate method invoke by child filterView.
    func passFilters(radius: Float, filters: [String]) {
        print(radius, filters)
//        radius = floor(radius)

        //Request goes here.
        if(filters.count > 0 || distanceRadius != radius){
            if(filters.count > 0){
                for item in filters{
                    let location = locationManager.location!
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    annotationManager.removeAllAnnotations()
//                    print("here is the distance", item)
                    let apiURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=\(item)&key=AIzaSyCx3Y1vXE0PBpdSLCjqGn6G3z8JcOvYfmo"
//                    print("APIURL: ", apiURL)
                    Alamofire.request(apiURL).responseJSON { response in
                        if let json = response.result.value {
//                            print("JSON: \(json)") // serialized json response
                            guard let responseDict = json as? NSDictionary else {
                                return
                            }
                            guard let placesArray = responseDict.object(forKey: "results") as? [NSDictionary] else { return }
                            for placeDict in placesArray {
                                let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                                let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                                let reference = placeDict.object(forKey: "reference") as! String
                                let name = placeDict.object(forKey: "name") as! String
                                let address = placeDict.object(forKey: "vicinity") as! String
                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                let rating = placeDict.object(forKey: "rating") as? Double ?? 0.0
                                let iconURL = placeDict.object(forKey: "icon") as! String
                                let placeID = placeDict.object(forKey: "place_id") as! String

                                print("This is the name:", name)
                                print("distance", radius)
                                //Create threads for every node.
                                DispatchQueue.main.async {
                                    Alamofire.request(URL(string: iconURL)!, method: .get).responseImage { response in
                                        if let icon = response.result.value {
                                            print("Creating annotations.")

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

    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        switch atIndex {
        case 0:
            print("home button pressed")
            break
        case 1:
            print("search button pressed")
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.present(autocompleteController, animated: false, completion: nil)
            })
            break
        case 2:
            print("filter button pressed")
            break
        case 3:
            print("Favs")

            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

            let fetchReq = NSFetchRequest<NSFetchRequestResult>()
            let entityDesc = NSEntityDescription.entity(forEntityName: "Place", in: context)
            fetchReq.entity = entityDesc

            do {
                let results = try context.fetch(fetchReq) as! [Place]
                if(results.count == 0) {
                    return
                } else{
                    print(results)
                    let favs = FavoritesListViewController()
                    favs.favoritePlaces = results
                    self.present(favs, animated: true, completion: nil)
                }

            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }




            break
        default:
            print("button will selected: \(atIndex)")
            break
        }
    }

    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        menuButton.backgroundColor = UIColor.lightGray
        menuButton.layer.cornerRadius = menuButton.frame.size.width / 2.0
        menuButton.delegate = self

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false

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


        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)

        // Declare tap gesture recognizer
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action:  #selector(tapped))
        sceneView.gestureRecognizers = [tapRecognizer]
    }

    @objc func tick() {
        timeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    }

    @IBAction func filterMenuClicked(_ sender: Any) {
        let filterView = storyboard?.instantiateViewController(withIdentifier: "filterMenuVC") as! FilterMenuViewController
        self.addChildViewController(filterView)
//        self.present(filterView, animated: true, completion: nil)
        self.view.addSubview(filterView.view)
    }

    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)

        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0] as SCNHitTestResult
            let node = result.node

            if let touchedNode = node as? customNode {

                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let detailView = storyBoard.instantiateViewController(withIdentifier: "detailsView") as! DetailViewController
                detailView.annotation = touchedNode.annotation
                self.present(detailView, animated: false, completion: nil)

            }
        }
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

                DispatchQueue.main.async {
                    Alamofire.request(URL(string: "http://api.openweathermap.org/data/2.5/weather?APPID=2ea48577574b26c2d63d4e3bfcb19d59&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)")!, method: .get).responseJSON { response in
                        if let json = response.result.value as? NSDictionary {
                            // print(json)
                            var temp = json.value(forKeyPath: "main.temp") as! Float
                            temp = temp * (9/5) - 459.67
                            temp = temp.rounded(.up)
                            let tempString = "\(temp)°F"
                            /*let tempNode = SCNText(string: tempString, extrusionDepth: 0.0)
                            tempNode.font = UIFont(name: "HelveticaNeue", size: 3.0)
                            let mainTempNode = SCNNode(geometry: tempNode)
                            // mainTempNode.transform.m41
                            mainTempNode.transform.m43 = -10.0
                            // mainTempNode.scale = SCNVector3(20, 20, 20)
                            self.sceneView.scene.rootNode.addChildNode(mainTempNode)*/
                            self.weatherLabel.text = tempString
                        }
                        /*if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            print("data: \(utf8Text)")
                        }*/
                    }
                }

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
                                let placeID = placeDict.object(forKey: "place_id") as! String

                                //Create threads for every node.
                                DispatchQueue.main.async {
                                    Alamofire.request(URL(string: iconURL)!, method: .get).responseImage { response in
                                        if let icon = response.result.value {

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
        print("camera did change tracking state: \(camera.trackingState)")

        switch camera.trackingState {
        case .normal:
            cameraStateLabel.text = "Ready!"
            UIView.animate(withDuration: 1, delay: 1, options: [], animations: {
                self.cameraStateLabel.alpha = 0
            }, completion: nil)

        default:
            cameraStateLabel.alpha = 1
            cameraStateLabel.text = "Move the camera"
        }
    }

    func node(for annotation: Annotation) -> SCNNode? {
        /*
         Parameters:
         Z-Depth: Placing the annotation in the field. (Float),
         Y-Coordinate: Placing the annotation at a height to minimize overlapping. (Float),
         Distance(Float)
         */


        var name : String = ""
        if(String(annotation.name).count >= 10) {
            let index = annotation.name.index(annotation.name.startIndex, offsetBy: 10)
            name = String(annotation.name[..<index])
            name = name + "..."
        } else {
            name = annotation.name
        }
        print("Test: Name: \(name)")
        //Create annotations on the street.

        let nameOfPlace = SCNText(string: name, extrusionDepth: 0.04)        //Replace string with incoming string value for every node.
        nameOfPlace.font = UIFont(name: "Futura", size: 0.3)        //Fontsize can be played around with. But 0.3 seems fine.
        nameOfPlace.firstMaterial!.diffuse.contents = UIColor.white
        nameOfPlace.firstMaterial!.specular.contents = UIColor.white

        //fetching min and max vounds of of the created geomtric entity.
        let max = nameOfPlace.boundingBox.max
        let min = nameOfPlace.boundingBox.min


        //Create Another text entity for distance.
        let compString = String(Int(ceil(annotation.distance))) + "mts"
        let dist = SCNText(string: compString, extrusionDepth: 0.04)
        dist.font = UIFont.init(name: "Futura", size: 0.15)
        dist.firstMaterial!.diffuse.contents = UIColor.blue

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
        annotSmall.firstMaterial?.diffuse.contents = UIColor(red: 234.0/255.0, green: 67.0/255.0, blue: 53.0/255.0, alpha: 0.7)
        if annotation.distance < 200.0 {
            annotSmall.firstMaterial?.diffuse.contents = UIColor(red: 52.0/255.0, green: 168.0/255.0, blue: 83.0/255.0, alpha: 0.7)
        } else if annotation.distance < 500.0 {
            annotSmall.firstMaterial?.diffuse.contents = UIColor(red: 251.0/255.0, green: 188.0/255.0, blue: 5.0/255.0, alpha: 0.7)
        } else {
            annotSmall.firstMaterial?.diffuse.contents = UIColor(red: 234.0/255.0, green: 67.0/255.0, blue: 53.0/255.0, alpha: 0.7)
        }
        annotSmall.cornerRadius = 0.5

        let annotNode = SCNNode(geometry: annotSmall)   //Create Node

        let posMin = annotSmall.boundingBox.min

        //Create nodes for all entities.
        let labelNode = customNode(geometry: nameOfPlace, annotation: annotation)
        let distNode = customNode(geometry: dist, annotation: annotation)
        let iconNode = customNode(geometry: icon, annotation: annotation)

        labelNode.position = SCNVector3(posMin.x + widthOfIcon + 0.2, -1.1, posMin.z + 0.1)
        distNode.position = SCNVector3(posMin.x + widthOfIcon + 0.2, -1.3, posMin.z + 0.1)
        iconNode.position = SCNVector3((posMin.x + widthOfIcon/2) + 0.1, 0, posMin.z + 0.1)

        //calculate scale for each node.


        //Make all nodes children ofa parent SCNPlane.
        annotNode.addChildNode(labelNode)
        annotNode.addChildNode(distNode)
        annotNode.addChildNode(iconNode)

        annotNode.scale = SCNVector3(20,20,20)

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

extension ViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.a
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")

        let text = "Navigating to \(place.name)"
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)

        dismiss(animated: false, completion: nil)

        let nav = storyBoard.instantiateViewController(withIdentifier: "NavViewController") as! NavViewController
        nav.currentLocation = locationManager.location!.coordinate
        let destinationLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        nav.locationManager = locationManager
        nav.destinationLocationCustom = destinationLocation
        self.present(nav, animated: false, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: false, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}

extension UIColor {
    static func color(_ red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        return UIColor(
            red: 1.0 / 255.0 * CGFloat(red),
            green: 1.0 / 255.0 * CGFloat(green),
            blue: 1.0 / 255.0 * CGFloat(blue),
            alpha: CGFloat(alpha))
    }
}
