//
//  FilterViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 11/21/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    internal var buttonToggle = false
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet var filterView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Blurring
        searchButton.layer.cornerRadius = 10
        searchButton.clipsToBounds = true
        
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = filterView.frame
        
        filterView.insertSubview(blurView, at: 0)

    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        distanceLabel.text = floor(distanceSlider.value).description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    public func updateVisibility(){
        
        if (self.view.isHidden && buttonToggle == false){
            self.buttonToggle = true
            self.view.isHidden = false
        }
        else if (!self.view.isHidden && buttonToggle == true){
            self.view.isHidden = true
            self.buttonToggle = false
        }
    }

    @IBAction func filter(_ sender: Any) {
        
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
