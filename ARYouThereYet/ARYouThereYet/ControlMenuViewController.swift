//
//  ControlMenuViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 11/21/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit

class ControlMenuViewController: UIViewController {

    var filterButton = false
    weak var delegate:menuDelegation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 3
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showFilterMenu(_ sender: Any) {
        delegate?.toggleVisibility(incomingContainer: "filter")
    }
    
    @IBAction func showSearchOptions(_ sender: Any) {
        delegate?.toggleVisibility(incomingContainer: "search")
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
