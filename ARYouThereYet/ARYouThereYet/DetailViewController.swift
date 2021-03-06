//
//  DetailViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 11/27/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import MapboxARKit
import GooglePlaces
import CoreData
import AVFoundation

class DetailViewController: UIViewController, ARSCNViewDelegate,CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    public var annotation : Annotation?
    var placeImage: UIImage?
    var currentPlace: GMSPlace?
    var photoIndex : Int = 0;
    var currentPlaceImages : [GMSPlacePhotoMetadata]? = []
    var placeImages : [UIImage]? = []
    let locationManager = CLLocationManager()
    
    let addFavMaterial = SCNMaterial()
    let remFavMaterial = SCNMaterial()
    
    var currentPlaceInFavoriteList  = false
    
    var favoritePlaces = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Config CLLocationManager object
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action:  #selector(tapped))
        sceneView.gestureRecognizers = [tapRecognizer]
        

        
        GMSPlacesClient.shared().lookUpPlaceID((annotation?.id)!) { (place, err) in
            
            if (err != nil) {
                self.dismiss(animated: true, completion: nil)
            }
            self.currentPlace = place
            if(self.isInFavoriteList()) {
                self.currentPlaceInFavoriteList = true
            }
            self.loadFirstPhotoForPlace(placeID: (place?.placeID)!)
        }
    }
    
    
    func isInFavoriteList() -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchReq = NSFetchRequest<NSFetchRequestResult>()
        let entityDesc = NSEntityDescription.entity(forEntityName: "Place", in: context)
        fetchReq.entity = entityDesc
        
        do {
            let results = try context.fetch(fetchReq) as! [Place]
            if(results.count != 0) {
                favoritePlaces = results
                for place in results {
                    if(place.name == currentPlace?.name) {
                        return true
                    }
                }
            }
        } catch {
            print("Error fetching results for favorite places")
        }
        return false
    }
    
    
    
// street_number route
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
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
    
    func getLocationAddress() -> String {
        var address : String = ""
        let addressComps = self.currentPlace?.addressComponents
        for comp : GMSAddressComponent in addressComps! {
            if(comp.type == "street_number") {
                address = address + comp.name + " "
            }
            if(comp.type == "route" ) {
                address = address + comp.name
            }
        }
        return address
    }
    
    func augmentDetailsView(place : GMSPlace, hasPhoto: Bool) {
        let mainAnchor = getMainPaneAnchor()
        let mainPlane  = getMainPane(withPhoto: hasPhoto)
        let mainNode = SCNNode(geometry: mainPlane)
        mainNode.name = "MainNode"
        mainNode.transform = getMainTransform()
        
        let locNameNode    = getNodeFor(locationName: place.name)
        let addressNode    = getNodeFor(address: getLocationAddress())
        let distanceNode   = getNodeFor(distance: Float((annotation?.distance)!))
        let openStatusNode = getNodeFor(openStatus: place.openNowStatus.rawValue)
        
        if place.phoneNumber != nil {
            let phoneNoNode    = getNodeFor(phoneNo: place.phoneNumber!)
            sceneView.scene.rootNode.addChildNode(phoneNoNode)
        }
        
        if place.website != nil {
            let websiteNode    = getNodeFor(website: (currentPlace?.website?.absoluteString)!)
            sceneView.scene.rootNode.addChildNode(websiteNode)
        
        }
        
        if ( place.priceLevel.rawValue != -1) {
            let priceNode      = getNodeFor(priceLevel: 3)
            sceneView.scene.rootNode.addChildNode(priceNode)
        
        }
        
        if (place.rating != nil) {
            addRatingStars(rating: 4.5, to: sceneView.scene.rootNode, at: [-4.5,3.7,-18.0])
        }
        
        if(hasPhoto) {
            let imgNode = getImageNode(forImage: placeImage!)
            sceneView.scene.rootNode.addChildNode(imgNode)
        }
        
    
        let backNode = getBackNode()
        
        let navNode = getNavigateNode()
        
        let favNode = getfavoriteNode()
        
        sceneView.session.add(anchor: mainAnchor)
        sceneView.scene.rootNode.addChildNode(mainNode)
        sceneView.scene.rootNode.addChildNode(locNameNode)
        sceneView.scene.rootNode.addChildNode(addressNode)
        sceneView.scene.rootNode.addChildNode(distanceNode)
        sceneView.scene.rootNode.addChildNode(openStatusNode)
        sceneView.scene.rootNode.addChildNode(backNode)
        sceneView.scene.rootNode.addChildNode(navNode)
        sceneView.scene.rootNode.addChildNode(favNode)
        
        if(!hasPhoto) {
            for node : SCNNode in sceneView.scene.rootNode.childNodes {
                if(node.name != "MainNode") {
                    node.transform.m42 = node.transform.m42 - 5
                }
                if(node.name == "MainNode") {
                    node.transform.m42 = -2.5
                }
                if(node.name == "backNode" || node.name == "navNode") {
                    node.transform.m42 = node.transform.m42 + 5.2
                }
                
                if(node.name == "addFavNode" || node.name == "remFavNode") {
                    node.transform.m42 = node.transform.m42 + 5.4
                }
            }
        }
        
    }
    
    
    
    
    
    func getfavoriteNode() -> SCNNode {
        
        self.addFavMaterial.diffuse.contents = UIImage(named: "star")
        self.remFavMaterial.diffuse.contents = UIImage(named: "starFilled")
        let favPlane = SCNPlane(width: 2.0, height: 2.0)
        favPlane.cornerRadius = 0.25
        favPlane.firstMaterial?.diffuse.contents = UIColor(red: 74/255.0, green: 35/255.0, blue: 90/255.0, alpha: 0.8)
        let favNode = SCNNode(geometry: favPlane)
        if(currentPlaceInFavoriteList) {
            favNode.geometry?.materials = [remFavMaterial]
            favNode.name = "remFavNode"
        } else {
            favNode.geometry?.materials = [addFavMaterial]
            favNode.name = "addFavNode"
        }
        
        favNode.transform.m43 = -18.0
        favNode.transform.m42 = -7.2
        favNode.transform.m41 = 0.0
        return favNode
    }
    
    
    func getBackNode() -> SCNNode {
        
        let backImgMaterial = SCNMaterial()
        backImgMaterial.diffuse.contents = UIImage(named: "back")
        let backPlane = SCNPlane(width: 2.0, height: 2.0)
        backPlane.cornerRadius = 0.25
        backPlane.firstMaterial?.diffuse.contents = UIColor(red: 74/255.0, green: 35/255.0, blue: 90/255.0, alpha: 0.8)
        let backkNode = SCNNode(geometry: backPlane)
        backkNode.geometry?.materials = [backImgMaterial]
        
        backkNode.name = "backNode"
        backkNode.transform.m43 = -18.0
        backkNode.transform.m42 = -7.2
        backkNode.transform.m41 = -4.5
        return backkNode
    }
    
    func getNavigateNode() -> SCNNode {
        let navigateImageMaterial = SCNMaterial()
        navigateImageMaterial.diffuse.contents = UIImage(named: "navigate")
        let navPlane = SCNPlane(width: 1.7, height: 1.7)
        navPlane.cornerRadius = 0.25
        navPlane.firstMaterial?.diffuse.contents = UIColor(red: 74/255.0, green: 35/255.0, blue: 90/255.0, alpha: 0.8)
        let navNode = SCNNode(geometry: navPlane)
        navNode.geometry?.materials = [navigateImageMaterial]
        navNode.name = "navNode"
        navNode.transform.m43 = -18.0
        navNode.transform.m42 = -7.3
        navNode.transform.m41 = 4.5
        return navNode
    }
    
    func getImageNode(forImage: UIImage) ->SCNNode{
        let mainImgMaterial = SCNMaterial()
        mainImgMaterial.diffuse.contents = forImage
        let mainImgPlane = SCNPlane(width: 9.0, height:5.0)
        mainImgPlane.cornerRadius = 0.25
        let mainImgNode = SCNNode(geometry: mainImgPlane)
        mainImgNode.geometry?.materials = [mainImgMaterial]
        mainImgNode.transform.m42 = -3.0
        mainImgNode.transform.m43 = -18.0
        mainImgNode.name = "ImageNode"
        return mainImgNode
    }
    
    func getNodeFor(priceLevel: Int) -> SCNNode{
        var priceString: String = ""
        if(priceLevel == 0) {
            priceString = "Free"
        } else {
            for _ in 0..<priceLevel-1 {
                priceString = priceString + "$ "
            }
        }
        
        let priceText = SCNText(string: "Price Level " + priceString, extrusionDepth: 0.04)
        priceText.font = UIFont(name: "Futura", size: 0.45)
        let priceNode = SCNNode(geometry: priceText)
        priceNode.transform.m43 = -18.0
        priceNode.transform.m42 = -0.5
        priceNode.transform.m41 = -1.5
        let priceColorMaterial = SCNMaterial()
        priceColorMaterial.diffuse.contents = UIColor.green
        priceNode.geometry?.materials = [priceColorMaterial]
        priceNode.name = "PriceNode"
        return priceNode
    }
    
    func getNodeFor(website: String) -> SCNNode {
        var webAddr : String = ""
        
        if(website.count >= 45) {
            let index = website.index(website.startIndex, offsetBy: 45)
            webAddr = String(website[..<index])
            webAddr = webAddr + "..."
        } else {
            webAddr = website
        }
        
        let webSiteText = SCNText(string: webAddr, extrusionDepth: 0.04)
        webSiteText.font = UIFont(name: "Arial", size: 0.45)
        let websiteNode = SCNNode(geometry: webSiteText)
        websiteNode.transform.m41 = -5.0
        websiteNode.transform.m42 = 0.0
        websiteNode.transform.m43 = -18.0
        websiteNode.name = "WebsiteNode"
        return websiteNode
    }
    
    func getNodeFor(phoneNo: String) -> SCNNode {
        let phoneNoStr = "Ph: " + phoneNo
        let phoneNoTxt  = SCNText(string: phoneNoStr, extrusionDepth: 0.04)
        phoneNoTxt.font = UIFont(name: "Futura", size: 0.45)
        let phoneNoNode = SCNNode(geometry: phoneNoTxt)
        phoneNoNode.transform.m41 = 0.8
        phoneNoNode.transform.m42 = 1.2
        phoneNoNode.transform.m43 = -18.0
        phoneNoNode.name = "PhoneNoNode"
        return phoneNoNode
    }
    
    
    func getNodeFor(distance: Float) -> SCNNode {
        let distanceString = String(Int(ceil(distance))) + " meters from here"
        let distanceText   = SCNText(string: distanceString, extrusionDepth: 0.04)
        distanceText.font  = UIFont(name: "Futura", size: 0.45)
        let distanceNode   = SCNNode(geometry: distanceText)
        distanceNode.transform.m43 = -18.0
        distanceNode.transform.m42 = 2.5
        distanceNode.transform.m41 = 0.8
        distanceNode.name = "distanceNode"
        return distanceNode
    }
    
    
    func getNodeFor(locationName : String) -> SCNNode {
        var name : String = ""
        if(locationName.count >= 32) {
            let index = locationName.index(locationName.startIndex, offsetBy: 32)
            name = String(locationName[..<index])
            name = name + "..."
        } else {
            name = locationName
        }
        
        let locName     = SCNText(string: name, extrusionDepth: 0.04)
        locName.font    = UIFont(name: "Futura", size: 0.6)
        let locNameNode = SCNNode(geometry: locName)
        locNameNode.transform.m43 = -18.0
        locNameNode.transform.m42 = 4.5
        locNameNode.transform.m41 = -5.0
        locNameNode.name = "LocationNameNode"
        return locNameNode
    }
    
    func getNodeFor(address: String) -> SCNNode {
        let addressText  = SCNText(string: address, extrusionDepth: 0.04)
        addressText.font = UIFont(name: "Futura", size: 0.55)
        let addressNode  = SCNNode(geometry: addressText)
        addressNode.transform.m43 = -18.0
        addressNode.transform.m42 = 3.5
        addressNode.transform.m41 = -5.0
        addressNode.name = "AddressNode"
        return addressNode
    }
    
    func getNodeFor(openStatus: Int) -> SCNNode {
        var openStatusString : String
        if(openStatus == 0) {
            openStatusString = "The place is open now"
        } else if(openStatus == 1){
            openStatusString = "The place is closed now"
        } else {
            openStatusString = "Open Status unknown"
        }
        
        let openStatusText = SCNText(string: openStatusString, extrusionDepth: 0.04)
        openStatusText.font = UIFont(name: "Futura", size: 0.45)
        let openStatusNode  = SCNNode(geometry: openStatusText)
        openStatusNode.transform.m41 = -5.0
        openStatusNode.transform.m42 = 1.2
        openStatusNode.transform.m43 = -18.0
        openStatusNode.name = "OpenStatusNode"
        return openStatusNode
    }
    
    func getMainPane(withPhoto: Bool) -> SCNPlane {
        // Main semi translucent plane upon which all the details view will be put on
        let mainPlane: SCNPlane = {  // Initialization with a closure
            var plane = SCNPlane()
            if(withPhoto) {
                plane = SCNPlane(width: 12.0, height: 14.0)
            } else {
                plane = SCNPlane(width: 12.0, height: 8.0)
                
            }
//            let mPlane = SCNPlane(width: 12.0, height: 8.0)
            plane.cornerRadius = 0.5
            plane.firstMaterial?.isDoubleSided = true
            //            mPlane.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(0/255), green: CGFloat(0/255), blue: CGFloat(0/255), alpha: 0.8)
            plane.firstMaterial?.diffuse.contents = UIColor(red: 74/255.0, green: 35/255.0, blue: 90/255.0, alpha: 0.8)
            return plane
        }()
        return mainPlane
    }
    
    func getMainPaneAnchor() -> ARAnchor {
        var position = matrix_identity_float4x4
        position.columns.3.z = -20
        return ARAnchor(transform: position)
    }
    
    func getMainTransform() -> SCNMatrix4 {
        let mainTransform : SCNMatrix4 = {
            var trans = SCNMatrix4()
            trans.m43 = -20
//            trans.m42 = 8.0
            trans.m11 = 1
            trans.m22 = 1
            trans.m33 = 1
            return trans
        }()
        return mainTransform
    }
    
    func addRatingStars(rating : Double, to: SCNNode, at:[Double]) {
        var mRating : Double
        let remainder = rating.truncatingRemainder(dividingBy: 1.0)
        if(remainder != 0 && remainder > 0.5) {
            mRating = floor(rating) + 0.5
        } else {
            mRating = floor(rating)
        }
        
        var x = at[0]
        let y = at[1]
        let z = at[2]
        
        for _ in 0..<Int(floor(mRating)) {
            let starMaterial = SCNMaterial()
            starMaterial.diffuse.contents = UIImage(named: "starFilled")
            
            let starPlane = SCNPlane(width: 1.0, height: 1.0)
            let starNode = SCNNode(geometry: starPlane)
            starNode.geometry?.materials = [starMaterial]
            starNode.transform.m41 = Float(x)
            starNode.transform.m42 = Float(y)
            starNode.transform.m43 = Float(z)
            starNode.scale = SCNVector3(0.6,0.6,0.6)
            x = x + 0.8
            
            to.addChildNode(starNode)
        }
        
        if(mRating.truncatingRemainder(dividingBy: 1.0) == 0.5) {
            let starMaterial = SCNMaterial()
            starMaterial.diffuse.contents = UIImage(named: "halfFilled")
            
            let starPlane = SCNPlane(width: 1.0, height: 1.0)
            let starNode = SCNNode(geometry: starPlane)
            starNode.geometry?.materials = [starMaterial]
            starNode.transform.m41 = Float(x)
            starNode.transform.m42 = Float(y)
            starNode.transform.m43 = Float(z)
            starNode.scale = SCNVector3(0.6,0.6,0.6)
            x = x + 0.8
            to.addChildNode(starNode)
        }
        
        let remaining = 5 - ceil(mRating)
        
        for _ in 0..<Int(remaining) {
            let starMaterial = SCNMaterial()
            starMaterial.diffuse.contents = UIImage(named: "star")
            
            let starPlane = SCNPlane(width: 1.0, height: 1.0)
            let starNode = SCNNode(geometry: starPlane)
            starNode.geometry?.materials = [starMaterial]
            starNode.transform.m41 = Float(x)
            starNode.transform.m42 = Float(y)
            starNode.transform.m43 = Float(z)
            starNode.scale = SCNVector3(0.6,0.6,0.6)
            x = x + 0.8
            to.addChildNode(starNode)
        }
        
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if error != nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.currentPlaceImages = photos?.results
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                    self.photoIndex = self.photoIndex + 1
                } else {
                    self.augmentDetailsView(place: self.currentPlace!, hasPhoto: false)
                }
            }
        }
    }
    
    func showNextImage(nextImage: UIImage) {
        let nodes = sceneView.scene.rootNode.childNodes
        for node : SCNNode in nodes {
            if (node.name == "ImageNode") {
                let material = SCNMaterial()
                material.diffuse.contents = nextImage
                node.geometry?.materials = [material]
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                
                print("Error: \(error.localizedDescription)")
                self.dismiss(animated: true, completion: nil)
            } else {
                self.placeImage = photo
                self.augmentDetailsView(place: self.currentPlace!, hasPhoto: true)
                self.placeImages?.append(photo!)
            }
        })
    }
    
    func loadNextImage(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata) { (image, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                self.showNextImage(nextImage: image!)
                self.placeImages?.append(image!)
            }
        }
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0] as SCNHitTestResult
            let node = result.node
            
            if let touchedNode = node as? SCNNode {
                
                if(touchedNode.name == "navNode") {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let nav = storyBoard.instantiateViewController(withIdentifier: "NavViewController") as! NavViewController
                    nav.currentLocation = locationManager.location!.coordinate
                    let destinationLocation = CLLocationCoordinate2D(latitude: (self.annotation?.latitude)!, longitude: (self.annotation?.longitude)!)
                    nav.destinationLocationCustom = destinationLocation
                    
                    let text = "Navigating to \(currentPlace!.name)"
                    let utterance = AVSpeechUtterance(string: text)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                    
                    self.present(nav, animated: false, completion: nil)
                    
                }
                
                else if(touchedNode.name == "ImageNode") {
                    if((self.placeImages!.count - 1) >= self.photoIndex) {
                        showNextImage(nextImage: self.placeImages![self.photoIndex])
                    } else {
                        loadNextImage(photoMetadata: self.currentPlaceImages![self.photoIndex])
                    }
                    
                    if((self.photoIndex + 1) == self.currentPlaceImages?.count) {
                        self.photoIndex = -1
                    }
                    self.photoIndex = self.photoIndex + 1
                } else if(touchedNode.name == "backNode") {
                    self.dismiss(animated: false, completion: nil)
                } else if(touchedNode.name == "addFavNode") {
                    
                    
                    remFavMaterial.diffuse.contents = UIImage(named: "starFilled")
                    touchedNode.geometry?.materials = [remFavMaterial]
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let place = Place(context: context)
                    place.name = currentPlace?.name
                    place.address = currentPlace?.formattedAddress
                    place.lattitude = (currentPlace?.coordinate.latitude)!
                    place.longitude = (currentPlace?.coordinate.longitude)!
                    place.placeID = currentPlace?.placeID
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    do {
                        try context.save()
                    } catch {
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    
                    touchedNode.name = "remFavNode"
                } else if (touchedNode.name == "remFavNode") {
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    var index = 0
                    for place in favoritePlaces {
                        if(place.name == currentPlace?.name) {
                            context.delete(place)
                            do {
                                try context.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                            break
                        }
                        index = index + 1
                    }
                    addFavMaterial.diffuse.contents = UIImage(named: "star")
                    touchedNode.geometry?.materials = [addFavMaterial]
                    touchedNode.name = "addFavNode"
                    self.currentPlaceInFavoriteList = false
                    favoritePlaces.remove(at: index)
                } else if(touchedNode.name == "WebsiteNode") {
                    
                    UIApplication.shared.openURL((currentPlace?.website)!)
                    
                } else if(touchedNode.name == "PhoneNoNode") {
                    
                    guard let place = self.currentPlace else {
                        return
                    }
                    var num = place.phoneNumber!
                    num = num.replacingOccurrences(of: "-", with: "")
                    num = num.replacingOccurrences(of: " ", with: "")
                    if let callUrl = URL(string: "tel:" + num) {
                        UIApplication.shared.openURL(callUrl)
                    }

                }
        }
    }
 }
}
