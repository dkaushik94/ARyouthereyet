//
//  FilterMenuViewController.swift
//  ARYouThereYet
//
//  Created by Debojit Kaushik  on 11/29/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import CloudTagView

class FilterMenuViewController: UIViewController {

    let cloudTagView = CloudTagView()
    var filters = [String]()

    @IBOutlet var filterMenuView: UIView!
    
    @objc func handleSwipeDown(){
        filterMenuView.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudTagView.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: 10)
        view.addSubview(cloudTagView)
        
        //Blur effect.
        let blur = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = view.frame
        view.insertSubview(blurEffectView, at: 0)
        cloudTagView.delegate = self
        
        setupTags()
    }
    
    fileprivate func setupTags() {
        let tags = ["accounting",
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
                    "zoo"
        ]
        
        for tag in tags {
            let tg = TagView(text: tag)
            tg.marginTop = 10
            tg.marginLeft = 20
            tg.iconImage = nil
            cloudTagView.tags.append(tg)
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

extension FilterMenuViewController: TagViewDelegate{
    
    //Delegate method for selecting and deselecting the filter tags.
    func tagTouched(_ tag: TagView) {
        if(self.filters.count < 3){
            if(tag.isSelected){
                tag.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
                filters = filters.filter{$0 != tag.text}
            }
            else if(!tag.isSelected){
                tag.backgroundColor = UIColor(red: (255/255.0), green: (162/255.0), blue: (38/255.0), alpha: 1)
                filters.append(tag.text)
            }
            tag.isSelected = !tag.isSelected
        }
        else{
            if(tag.isSelected){
                tag.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
                filters = filters.filter{$0 != tag.text}
            }
        }
    }
}
