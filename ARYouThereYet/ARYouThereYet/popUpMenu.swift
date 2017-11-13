//
//  popUpMenu.swift
//  ARYouThereYet
//
//  Created by Debojit Kaushik  on 11/8/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit


class popUpMenu: UIViewController {

   
    @IBOutlet weak var menuContainer: UIView!
    @IBOutlet weak var filterView: UIView!
    var filViewController:  filterMenuViewController?
    
    //Delegation for communication between containers.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let parentVC = segue.destination as? menuItemsViewController
        
        parentVC?.delegate = self
        if let filterVC = segue.destination as? filterMenuViewController{
            filViewController = filterVC
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        menuContainer.viewWithTag(1)?.backgroundColor = UIColor.clear
        
        // Do any additional setup after loading the view.
        self.menuAnimation()
        
        //Blurring
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = menuContainer.viewWithTag(1)!.frame
        
        menuContainer.viewWithTag(1)!.insertSubview(blurEffectView, at: 0)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Close menu.
    @IBAction func closeMenu(_ sender: Any) {
        self.discardMenuAnimation()
    }
    
    //Menu showing animation.
    func menuAnimation(){
        menuContainer.viewWithTag(1)?.transform = CGAffineTransform(scaleX:2.0, y:2.0)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1
            self.menuContainer.viewWithTag(1)?.transform = CGAffineTransform(scaleX:1.0, y:1.0)
        })
    }
    
    //Menu quitting animation.
    func discardMenuAnimation(){
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
            self.menuContainer.viewWithTag(1)?.transform = CGAffineTransform(scaleX:2.0, y:2.0)
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
extension popUpMenu: menuDelegation {
    func toggleVisibility() {
        print("Delegation Successful!")
        self.filViewController?.updateVisibility()
    }
}
