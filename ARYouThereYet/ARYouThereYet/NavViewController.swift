//
//  NavViewController.swift
//  ARYouThereYet
//
//  Created by Amlaan Bhoi on 11/22/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import ARKit

class NavViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("navController on")
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func backButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        /*@IBAction func goBack(sender: AnyObject) {
            self.dismissViewControllerAnimated(true) {
                self.delegate!.dismissViewController()
            }
        }*/
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
