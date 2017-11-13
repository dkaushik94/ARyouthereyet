//
//  menuItemsViewController.swift
//  ARYouThereYet
//
//  Created by Debojit Kaushik  on 11/9/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit

class menuItemsViewController: UIViewController {

    var filterButton = false
    weak var delegate:menuDelegation?
    
    @IBAction func filterMenu(_ sender: Any) {
        delegate?.toggleVisibility()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

//    @IBAction func showFilters(_ sender: Any) {
//        if (!filterButton){
//            self.filterButton = true
//            filterMenu.containerVisibility(status: true)
//        }
//        else{
//            self.filterButton = false
//            filterMenu.containerVisibility(status: false)
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
