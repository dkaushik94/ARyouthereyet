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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    //Creating a annotation in the form of a composite node.
    @IBAction func addCube(_ sender: Any) {
        
        //Generate random values for annotations.
        let zDepth = arc4random_uniform(10)
        let yCoordinate = arc4random_uniform(3)
        self.createAnnotation(zDepth: CGFloat(zDepth+1), yCoordinate: CGFloat(yCoordinate+1))
    }
    
    //Creating annotation.
    private func createAnnotation(zDepth: CGFloat, yCoordinate: CGFloat){
        
        /*
         Parameters:
         Z-Depth: Placing the annotation in the field. (Float)
         Y-Coordinate: Placing the annotation at a height to minimize overlapping. (Float)
         */
        
        //Create annotations on the street.
        let nameOfPlace = SCNText(string: "Coffee Alley, W. Taylor St", extrusionDepth: 0.1)        //Replace string with incoming string value for every node.
        nameOfPlace.font = UIFont(name: "Futura", size: 0.3)        //Fontsize can be played around with. But 0.3 seems fine.
        nameOfPlace.firstMaterial!.diffuse.contents = UIColor.white
        nameOfPlace.firstMaterial!.specular.contents = UIColor.white
        
        let max = nameOfPlace.boundingBox.max       //fetching min and max vounds of of the created geomtric entity.
        let min = nameOfPlace.boundingBox.min
        
        //Create Another text entity for distance.
        let compString = "0.3" + "miles"
        let dist = SCNText(string: compString, extrusionDepth: 0.1)
        dist.font = UIFont.init(name: "Futura", size: 0.15)
        dist.firstMaterial!.diffuse.contents = UIColor.white
        
        //Create holding geometry and corresponding node for icon.
        let icon = SCNPlane(width: 0.5, height: 0.5)
        let iconMaterial = SCNMaterial()
        iconMaterial.diffuse.contents = UIImage(named: "coffeeIcon")
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
        annotNode.position = SCNVector3(0, yCoordinate, -zDepth)       //Z-Depth is hardcoded. Again, set according to the incoming value.
        
        let posMin = annotSmall.boundingBox.min
        
        //Create nodes for all entities.
        let labelNode = SCNNode(geometry: nameOfPlace)
        let distNode = SCNNode(geometry: dist)
        let iconNode = SCNNode(geometry: icon)
        
        labelNode.position = SCNVector3(posMin.x + widthOfIcon + 0.2, -1.1, posMin.z)
        distNode.position = SCNVector3(posMin.x + widthOfIcon + 0.2, -1.3, posMin.z)
        iconNode.position = SCNVector3((posMin.x + widthOfIcon/2) + 0.1, 0, posMin.z + 0.01)
        
        //Make all nodes children ofa parent SCNPlane.
        annotNode.addChildNode(labelNode)
        annotNode.addChildNode(distNode)
        annotNode.addChildNode(iconNode)
        
        //Attach all nodes to the root view.
        sceneView.scene.rootNode.addChildNode(annotNode)
    }
    
    @IBAction func addMenu(_ sender: Any) {
        
    }
    
    
    @IBAction func menuPopUp(_ sender: Any) {
        
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpMenuVC") as!
            popUpMenu
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Useless BoilerPlate code.
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false

        
        //Custom Code.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
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
}
