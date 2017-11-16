//
//  searchViewController.swift
//  ARYouThereYet
//
//  Created by Debojit Kaushik  on 11/13/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit

class searchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchBox: UITextField!
    
    var searchToggle = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //Blurring.
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.frame
        blurView.clipsToBounds = true
        self.view.insertSubview(blurView, at:0)
        self.searchBox.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchBox.resignFirstResponder()
        return true
    }

    public func updateVisibility(){
        
        if (self.view.isHidden && searchToggle == false){
            self.searchToggle = true
            self.view.isHidden = false
        }
        else if (!self.view.isHidden && searchToggle == true){
            self.view.isHidden = true
            self.searchToggle = false
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
