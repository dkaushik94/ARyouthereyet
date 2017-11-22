//
//  MainMenuViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 11/21/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var controlView: UIView!
    
    var filterViewController :FilterViewController?
    var searchViewController :SearchViewController?
    
    //Delegation for communication between containers.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let parentVC = segue.destination as? ControlMenuViewController
        parentVC?.delegate = self
        
        
        if let filterVC = segue.destination as? FilterViewController{
            filterViewController = filterVC
        }
        if let searchVC = segue.destination as? SearchViewController{
            searchViewController = searchVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        controlView.viewWithTag(1)?.backgroundColor = UIColor.clear

        // Do any additional setup after loading the view.
        self.menuAnimation()

        //Blurring
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = controlView.viewWithTag(1)!.frame

        controlView.viewWithTag(1)!.insertSubview(blurEffectView, at: 0)
        controlView.layer.cornerRadius = 2
        
        filterView.isHidden = true
        searchView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeMenus(_ sender: Any) {
        self.discardMenuAnimation()
        
    }
    //Menu showing animation.
    func menuAnimation(){
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1
        })
    }
    
    //Menu quitting animation.
    func discardMenuAnimation(){
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        },completion :{
            (finished: Bool) in
            if(finished){
                self.view.removeFromSuperview()
            }
        })
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

extension MainMenuViewController: menuDelegation {
    func toggleVisibility(incomingContainer: String) {
        if(incomingContainer == "search"){
            filterView.isHidden = true
            searchView.isHidden = false
            
        }
        else if(incomingContainer == "filter"){
            filterView.isHidden = false
            searchView.isHidden = true
        }
    }
}
