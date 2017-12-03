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
    var distanceRadius: Float?
    var collectedFilters: [String]?
    var filterDict: [String:String]?
    
    
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
        
        //Tags list.
        filterDict = ["ATM": "atm", "Hospital": "hospital", "Department Store": "department_store", "Clothing Store": "clothing_store", "Mosque": "mosque", "Rv Park": "rv_park", "Store": "store", "Synagogue": "synagogue", "Night Club": "night_club", "Restaurant": "restaurant", "Cafe": "cafe", "Amusement Park": "amusement_park", "Shoe Store": "shoe_store", "University": "university", "Parking": "parking", "Transit Station": "transit_station", "City Hall": "city_hall", "Storage": "storage", "Insurance Agency": "insurance_agency", "Meal Delivery": "meal_delivery", "Movie Rental": "movie_rental", "Bowling Alley": "bowling_alley", "Library": "library", "Meal Takeaway": "meal_takeaway", "Taxi Stand": "taxi_stand", "Book Store": "book_store", "Liquor Store": "liquor_store", "Electrician": "electrician", "Roofing Contractor": "roofing_contractor", "Home Goods Store": "home_goods_store", "Accounting": "accounting", "Bar": "bar", "Church": "church", "Hindu Temple": "hindu_temple", "Gas Station": "gas_station", "Subway Station": "subway_station", "Museum": "museum", "Zoo": "zoo", "Hardware Store": "hardware_store", "Shopping Mall": "shopping_mall", "Gym": "gym", "Airport": "airport", "Car Wash": "car_wash", "Locksmith": "locksmith", "Local Government Office": "local_government_office", "Physiotherapist": "physiotherapist", "Funeral Home": "funeral_home", "Lawyer": "lawyer", "Bicycle Store": "bicycle_store", "Jewelry Store": "jewelry_store", "Police": "police", "Hair Care": "hair_care", "Veterinary Care": "veterinary_care", "Post Office": "post_office", "Casino": "casino", "Dentist": "dentist", "School": "school", "Real Estate Agency": "real_estate_agency", "Doctor": "doctor", "Travel Agency": "travel_agency", "Pharmacy": "pharmacy", "Pet Store": "pet_store", "Bus Station": "bus_station", "Courthouse": "courthouse", "Stadium": "stadium", "Car Rental": "car_rental", "Plumber": "plumber", "Cemetery": "cemetery", "Car Dealer": "car_dealer", "Bank": "bank", "Convenience Store": "convenience_store", "Art Gallery": "art_gallery", "Car Repair": "car_repair", "Laundry": "laundry", "Beauty Salon": "beauty_salon", "Train Station": "train_station", "Florist": "florist", "Movie Theater": "movie_theater", "Electronics Store": "electronics_store", "Lodging": "lodging", "Campground": "campground", "Furniture Store": "furniture_store", "Embassy": "embassy", "Spa": "spa", "Fire Station": "fire_station", "Painter": "painter", "Bakery": "bakery", "Aquarium": "aquarium", "Park": "park", "Moving Company": "moving_company"]
        
        tagView?.allTags = Array(filterDict!.keys)
        
        distanceSelector.backgroundColor = UIColor.clear
        doneBtn.backgroundColor = UIColor.cyan
    
        self.doneBtn.isUserInteractionEnabled = true
//        self.view.backgroundColor = UIColor.color(240, green: 128, blue: 128, alpha: 1)
    }

    @IBOutlet weak var distanceSelector: CircularSlider!
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Invoke request method for parent view.
    func collectFilters(){
        self.distanceRadius = distanceSelector.value
        self.collectedFilters = [String]()
        collectedFilters = self.tagView?.chosenTags as? [String]
        
        var filters = [String]()
        for item in collectedFilters!{
            filters.append(filterDict![item]!)
        }
        
        let parentVC = self.parent as! ViewController
        parentVC.passFilters(radius: self.distanceRadius!, filters: filters)
    }
    
    
    @IBAction func doneClicked(_ sender: Any) {
        self.collectFilters()
        self.view.isHidden = true
    }
    
    @IBOutlet weak var doneBtn: UIButton!

    @IBAction func handleDismiss(_ sender: Any) {
        self.view.isHidden = true
    }
}

