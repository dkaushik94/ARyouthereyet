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


class DetailViewController: UIViewController, ARSCNViewDelegate,CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    public var annotation : Annotation?
    var placeImage: UIImage?
    var currentPlace: GMSPlace?
    var photoIndex : Int = 0;
    var currentPlaceImages : [GMSPlacePhotoMetadata]? = []
    var placeImages : [UIImage]? = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Config CLLocationManager object
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
//        locationManager.startUpdatingLocation()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action:  #selector(tapped))
        sceneView.gestureRecognizers = [tapRecognizer]
        
        GMSPlacesClient.shared().lookUpPlaceID((annotation?.id)!) { (place, err) in
            
            if (err != nil) {
                self.dismiss(animated: true, completion: nil)
            }
            
//            self.augmentDetailsView(place: place!, hasPhoto: true)
            self.currentPlace = place
            self.loadFirstPhotoForPlace(placeID: (place?.placeID)!)
        }
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
        
        if let phNo = place.phoneNumber {
            let phoneNoNode    = getNodeFor(phoneNo: place.phoneNumber!)
            sceneView.scene.rootNode.addChildNode(phoneNoNode)
        }
        
        if let website = place.website {
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
        
        
        sceneView.session.add(anchor: mainAnchor)
        sceneView.scene.rootNode.addChildNode(mainNode)
        sceneView.scene.rootNode.addChildNode(locNameNode)
        sceneView.scene.rootNode.addChildNode(addressNode)
        sceneView.scene.rootNode.addChildNode(distanceNode)
        sceneView.scene.rootNode.addChildNode(openStatusNode)
        sceneView.scene.rootNode.addChildNode(backNode)
        sceneView.scene.rootNode.addChildNode(navNode)
        
        if(!hasPhoto) {
            for node : SCNNode in sceneView.scene.rootNode.childNodes {
                if(node.name != "MainNode") {
                    print(node.name)
                    node.transform.m42 = node.transform.m42 - 5
                }
                if(node.name == "MainNode") {
                    node.transform.m42 = -2.5
                }
                if(node.name == "backNode" || node.name == "navNode") {
                    node.transform.m42 = node.transform.m42 + 5.2
                }
            }
        }
        
    }
    
    
    
    func getBackNode() -> SCNNode {
        
        let backImgMaterial = SCNMaterial()
        backImgMaterial.diffuse.contents = UIImage(named: "back")
        let backPlane = SCNPlane(width: 2.0, height: 2.0)
        backPlane.cornerRadius = 0.25
        backPlane.firstMaterial?.diffuse.contents = UIColor(red: 74/255.0, green: 35/255.0, blue: 90/255.0, alpha: 0.8)
        let backkNode = SCNNode(geometry: backPlane)
        backkNode.geometry?.materials = [backImgMaterial]
        
//        let backText = SCNText(string: "Done", extrusionDepth: 0.04)
//        backText.font = UIFont(name: "Arial", size: 1.3)
//        let backNode = SCNNode(geometry: backText)
//        let backColorMaterial = SCNMaterial()
//        backColorMaterial.diffuse.contents = UIColor.red
//        backNode.geometry?.materials = [backColorMaterial]
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
        for _ in 0..<priceLevel {
            priceString = priceString + "$ "
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
        print(webAddr)
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
            if let error = error {
                
                print("Error: \(error.localizedDescription)")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("No of Photos : \(photos?.results.count)")
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
//                node.geometry?.materials = nil
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
                    self.present(nav, animated: true, completion: nil)
                    
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
                }
        }
    }
 }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
