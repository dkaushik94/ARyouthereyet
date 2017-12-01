//
//  FilterMenuViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 11/30/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import PARTagPicker
import CircularSlider

class FilterMenuViewController: UIViewController {

    var tagView : PARTagPickerViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tagView = PARTagPickerViewController()
        tagView?.view.backgroundColor! = UIColor.darkGray
        tagView?.view.frame = CGRect(x: 0, y: 20, width: self.view.bounds.width, height: 220)
        self.view.addSubview((tagView?.view)!)
        tagView?.allowsNewTags = false
        self.addChildViewController(tagView!)
        tagView?.didMove(toParentViewController: self)
        tagView?.visibilityState = PARTagPickerVisibilityState.topAndBottom
        tagView?.view.backgroundColor = UIColor.clear
        
        //BlurView
        let blur = UIBlurEffect(style: .dark)
        let blurEffect = UIVisualEffectView(effect: blur)
        blurEffect.frame = self.view.frame
        self.view.insertSubview(blurEffect, at:0)
        
        tagView?.allTags = ["accounting",
                            "airport",
                            "amusement_park",
                            "aquarium",
                            "art_gallery",
                            "atm",
                            "bakery",
                            "bank",
                            "bar",
                            "beauty_salon",
                            "bicycle_store",
                            "book_store",
                            "bowling_alley",
                            "bus_station",
                            "cafe",
                            "campground",
                            "car_dealer",
                            "car_rental",
                            "car_repair",
                            "car_wash",
                            "casino",
                            "cemetery",
                            "church",
                            "city_hall",
                            "clothing_store",
                            "convenience_store",
                            "courthouse",
                            "dentist",
                            "department_store",
                            "doctor",
                            "electrician",
                            "electronics_store",
                            "embassy",
                            "finance",
                            "fire_station",
                            "florist",
                            "food",
                            "funeral_home",
                            "furniture_store",
                            "gas_station",
                            "general_contractor",
                            "grocery_or_supermarket",
                            "gym", "hair_care",
                            "hardware_store",
                            "health",
                            "hindu_temple",
                            "home_goods_store",
                            "hospital",
                            "insurance_agency",
                            "jewelry_store",
                            "laundry",
                            "lawyer",
                            "library",
                            "liquor_store",
                            "local_government_office",
                            "locksmith", "lodging",
                            "meal_delivery",
                            "meal_takeaway",
                            "mosque",
                            "movie_rental",
                            "movie_theater",
                            "moving_company",
                            "museum",
                            "night_club",
                            "painter",
                            "park",
                            "parking",
                            "pet_store",
                            "pharmacy",
                            "physiotherapist",
                            "place_of_worship",
                            "plumber",
                            "police",
                            "post_office",
                            "real_estate_agency",
                            "restaurant",
                            "roofing_contractor",
                            "rv_park",
                            "school",
                            "shoe_store",
                            "shopping_mall",
                            "spa",
                            "stadium",
                            "storage",
                            "store",
                            "subway_station",
                            "synagogue",
                            "taxi_stand",
                            "train_station",
                            "transit_station",
                            "travel_agency",
                            "university",
                            "veterinary_care",
                            "zoo"]
        
//        distanceSelector.frame.size = CGSize(width: 250, height: 250)
//        distanceSelector.frame.origin = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/3)
//        distanceSelector.si
        distanceSelector.backgroundColor = UIColor.clear
        doneBtn.backgroundColor = UIColor.cyan
        
        
        
    }

    @IBOutlet weak var distanceSelector: CircularSlider!
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func doneClicked(_ sender: Any) {
        print("DONE DONE")
        self.view.isHidden = true
    }
    
    @IBOutlet weak var doneBtn: UIButton!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
