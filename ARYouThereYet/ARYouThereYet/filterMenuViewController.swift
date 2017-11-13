//
//  filterMenuViewController.swift
//  ARYouThereYet
//
//  Created by Debojit Kaushik  on 11/10/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit

class filterMenuViewController: UIViewController {

    
    internal var buttonToggle = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func updateVisibility(){
        print("Effect")
        if (self.view.isHidden && buttonToggle == false){
            self.buttonToggle = true
            self.view.isHidden = false
        }
        else if (!self.view.isHidden && buttonToggle == true){
            self.view.isHidden = true
            self.buttonToggle = false
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
