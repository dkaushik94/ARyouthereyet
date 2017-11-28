//
//  DetailViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 11/27/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import MapboxARKit
import SceneKit
import ARKit

class DetailViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    public var annotation : Annotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func augmentDetailsView() {
        let mainAnchor = getMainPaneAnchor()
        let mainPlane  = getMainPane()
        let mainNode = SCNNode(geometry: mainPlane)
        mainNode.transform = getMainTransform()
        
        let locNameNode    = getNodeFor(locationName: "Richard Daley Library")
        let addressNode    = getNodeFor(address: "1200 W Harrison St, Chicago 60612, IL, USA")
        let distanceNode   = getNodeFor(distance: 1.8)
        let openStatusNode = getNodeFor(openStatus: 0)
        //        if let phNo = place.phoneNumber {
        let phoneNoNode    = getNodeFor(phoneNo: "+1 312 764 9845")
        //            mainNode.addChildNode(phoneNoNode)
        sceneView.scene.rootNode.addChildNode(phoneNoNode)
        //        }
        //        if let website = place.website {
        let websiteNode    = getNodeFor(website: "www.uic.edu")
        sceneView.scene.rootNode.addChildNode(websiteNode)
        //            mainNode.addChildNode(websiteNode)
        //        }
        //        if ( place.priceLevel.rawValue != -1) {
        let priceNode      = getNodeFor(priceLevel: 3)
        sceneView.scene.rootNode.addChildNode(priceNode)
        //            mainNode.addChildNode(priceNode)
        //        }
        //        if (place.rating != nil) {
        
        addRatingStars(rating: 4.5, to: sceneView.scene.rootNode, at: [-4.5,3.7,-18.0])
        //        }
        
        let imgNode = getImageNode()
        
        //        mainNode.addChildNode(locNameNode)
        //        mainNode.addChildNode(addressNode)
        //        mainNode.addChildNode(distanceNode)
        //        mainNode.addChildNode(openStatusNode)
        //        mainNode.addChildNode(imgNode)
        
        
        //        for node : SCNNode in mainNode.childNodes {
        //            node.transform.m42 = node.transform.m42 - 7
        //        }
        sceneView.session.add(anchor: mainAnchor)
        sceneView.scene.rootNode.addChildNode(mainNode)
        sceneView.scene.rootNode.addChildNode(locNameNode)
        sceneView.scene.rootNode.addChildNode(addressNode)
        sceneView.scene.rootNode.addChildNode(distanceNode)
        sceneView.scene.rootNode.addChildNode(openStatusNode)
        sceneView.scene.rootNode.addChildNode(imgNode)
        
    }
    
    func getImageNode() ->SCNNode{
        let mainImgMaterial = SCNMaterial()
        mainImgMaterial.diffuse.contents = UIImage(named : "ERFMain")
        let mainImgPlane = SCNPlane(width: 9.0, height:5.0)
        mainImgPlane.cornerRadius = 0.5
        let mainImgNode = SCNNode(geometry: mainImgPlane)
        mainImgNode.geometry?.materials = [mainImgMaterial]
        mainImgNode.transform.m42 = -3.0
        mainImgNode.transform.m43 = -18.0
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
        webSiteText.font = UIFont(name: "Futura", size: 0.45)
        let websiteNode = SCNNode(geometry: webSiteText)
        websiteNode.transform.m41 = -5.0
        websiteNode.transform.m42 = 0.0
        websiteNode.transform.m43 = -18.0
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
        return phoneNoNode
    }
    
    
    func getNodeFor(distance: Float) -> SCNNode {
        let distanceString = String(distance) + " miles from here"
        let distanceText   = SCNText(string: distanceString, extrusionDepth: 0.04)
        distanceText.font  = UIFont(name: "Futura", size: 0.45)
        let distanceNode   = SCNNode(geometry: distanceText)
        distanceNode.transform.m43 = -18.0
        distanceNode.transform.m42 = 2.5
        distanceNode.transform.m41 = 0.8
        return distanceNode
    }
    
    
    func getNodeFor(locationName : String) -> SCNNode {
        var name : String = ""
        if(locationName.count >= 32) {
            let index = locationName.index(locationName.startIndex, offsetBy: 32)
            var name = locationName[..<index]
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
        return locNameNode
    }
    
    func getNodeFor(address: String) -> SCNNode {
        let addressText  = SCNText(string: address, extrusionDepth: 0.04)
        addressText.font = UIFont(name: "Futura", size: 0.45)
        let addressNode  = SCNNode(geometry: addressText)
        addressNode.transform.m43 = -18.0
        addressNode.transform.m42 = 3.5
        addressNode.transform.m41 = -5.0
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
        return openStatusNode
    }
    
    func getMainPane() -> SCNPlane {
        // Main semi translucent plane upon which all the details view will be put on
        let mainPlane: SCNPlane = {  // Initialization with a closure
            let mPlane = SCNPlane(width: 12.0, height: 14.0)
            mPlane.cornerRadius = 0.5
            mPlane.firstMaterial?.isDoubleSided = true
            //            mPlane.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(0/255), green: CGFloat(0/255), blue: CGFloat(0/255), alpha: 0.8)
            mPlane.firstMaterial?.diffuse.contents = UIColor(red: 74/255.0, green: 35/255.0, blue: 90/255.0, alpha: 0.8)
            return mPlane
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

}
