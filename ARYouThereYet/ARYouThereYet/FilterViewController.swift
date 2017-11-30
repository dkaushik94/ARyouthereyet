//
//  FilterViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 11/21/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import MapboxARKit

class FilterViewController: UIViewController {

    internal var buttonToggle = false
    @IBOutlet weak var distanceSlider: UISlider!
    public var locationManager: CLLocationManager!
    public var listOfAnnotations: [Annotation] = []
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    //Outlets for each filter button.
    @IBOutlet weak var barFilter: UIButton!
    @IBOutlet weak var cafeFilter: UIButton!
    @IBOutlet weak var bankFilter: UIButton!
    @IBOutlet weak var doctorFilter: UIButton!
    @IBOutlet weak var libraryFilter: UIButton!
    @IBOutlet weak var policeFilter: UIButton!
    @IBOutlet weak var restaurantFilter: UIButton!
    @IBOutlet weak var atmFilter: UIButton!
    @IBOutlet weak var universityFilter: UIButton!
    
    @IBOutlet var buttonCollection: [UIButton]!
    
    //Array of selected filters to be collected when search is initiated.
    public var filters = [String]()
    public var filterCount = 0      //Count to limit filters to a max of 3.
    
    @IBOutlet weak var distanceRangeLabel: UILabel!
    @IBOutlet var filterView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    
    //IBActions for each filter tab.
    @IBAction func cafeToggle(_ sender: Any) {
        let button = "cafe"
        toggleFilter(label: button)
    }
    @IBAction func bankToggle(_ sender: Any) {
        let button = "bank"
        toggleFilter(label: button)
    }
    @IBAction func barToggle(_ sender: Any) {
        let button = "bar"
        toggleFilter(label: button)
    }
    @IBAction func libraryToggle(_ sender: Any) {
        let button = "library"
        toggleFilter(label: button)
    }
    @IBAction func doctorToggle(_ sender: Any) {
        let button = "doctor"
        toggleFilter(label: button)
    }
    @IBAction func restaurantToggle(_ sender: Any) {
        let button = "restaurant"
        toggleFilter(label: button)
    }
    @IBAction func policeToggle(_ sender: Any) {
        let button = "police"
        toggleFilter(label: button)
    }
    @IBAction func uniToggle(_ sender: Any) {
        let button = "university"
        toggleFilter(label: button)
    }
    @IBAction func atmToggle(_ sender: Any) {
        let button = "atm"
        toggleFilter(label: button)
    }
    
    //Method to grey and disable all filters once 3 filters are selected.
    public func disableFilters(){
        for item in self.buttonCollection{
            if(!item.isSelected){
                item.isEnabled = false
                item.setTitleColor(UIColor.gray, for: .disabled)
            }
        }
    }
    //Method to enable and colorize all filters once self.filterCount drops below 3.
    public func enableFilters(){
        for item in self.buttonCollection{
            if(!item.isEnabled){
                item.isEnabled = true
                item.setTitleColor(UIColor(red:(14/200.0), green: (122/255.0), blue:(254/255.0), alpha: 1.0), for: .normal)
            }
        }
    }
    
    
    //Toggle filter buttons.
    func toggleFilter(label: String){
        switch label {
        case "cafe":
            if(self.filterCount < 3){
                if(cafeFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                cafeFilter.isSelected = !cafeFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(cafeFilter.isSelected){
                    cafeFilter.isSelected = !cafeFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "bank":
            if(self.filterCount < 3){
                if(bankFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                bankFilter.isSelected = !bankFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(bankFilter.isSelected){
                    bankFilter.isSelected = !bankFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "bar":
            if(self.filterCount < 3){
                if(barFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                barFilter.isSelected = !barFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(barFilter.isSelected){
                    barFilter.isSelected = !barFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "library":
            if(self.filterCount < 3){
                if(libraryFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                libraryFilter.isSelected = !libraryFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(libraryFilter.isSelected){
                    libraryFilter.isSelected = !libraryFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "doctor":
            if(self.filterCount < 3){
                if(doctorFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                doctorFilter.isSelected = !doctorFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(doctorFilter.isSelected){
                    doctorFilter.isSelected = !doctorFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "atm":
            if(self.filterCount < 3){
                if(atmFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                atmFilter.isSelected = !atmFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(atmFilter.isSelected){
                    atmFilter.isSelected = !atmFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "police":
            if(self.filterCount < 3){
                if(policeFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                policeFilter.isSelected = !policeFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(policeFilter.isSelected){
                    policeFilter.isSelected = !policeFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "university":
            if(self.filterCount < 3){
                if(universityFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                universityFilter.isSelected = !universityFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(universityFilter.isSelected){
                    universityFilter.isSelected = !universityFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        case "restaurant":
            if(self.filterCount < 3){
                if(restaurantFilter.isSelected){
                    self.filterCount -= 1
                }
                else{
                    self.filterCount += 1
                }
                restaurantFilter.isSelected = !restaurantFilter.isSelected
                if(self.filterCount == 3){
                    self.disableFilters()
                }
            }
            else if(self.filterCount == 3){
                if(restaurantFilter.isSelected){
                    restaurantFilter.isSelected = !restaurantFilter.isSelected
                    self.enableFilters()
                    self.filterCount -= 1
                }
            }
        default:
            print("No valid option selected.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Blurring of the superimposed filter view.
        searchButton.layer.cornerRadius = 10
        searchButton.clipsToBounds = true
        
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = filterView.frame
        
        filterView.insertSubview(blurView, at: 0)
        
        distanceRangeLabel.text = floor(distanceSlider.value).description
    }
    //Method to collect filters selected for filtering the view.
    @IBAction func searchButtonTouched(_ sender: Any){
        if(filters.count != 0){
            filters.removeAll()
        }
        for item in buttonCollection {
            if(item.isSelected){
                filters.append((item.titleLabel?.text?.lowercased())!)
                let location = locationManager.location!
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                let itemTitleLabel = item.titleLabel!
                var itemText = itemTitleLabel.text!
                itemText = itemText.lowercased()
                let apiURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(distanceSlider.value)&type=\(itemText)&key=AIzaSyCx3Y1vXE0PBpdSLCjqGn6G3z8JcOvYfmo"
                Alamofire.request(apiURL).responseJSON { response in
                    if let json = response.result.value {
//                        print("JSON: \(json)") // serialized json response
                        guard let responseDict = json as? NSDictionary else {
                            return
                        }
                        guard let placesArray = responseDict.object(forKey: "results") as? [NSDictionary] else { return }
                        for placeDict in placesArray {
                            let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                            let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                            let reference = placeDict.object(forKey: "reference") as! String
                            let name = placeDict.object(forKey: "name") as! String
                            let address = placeDict.object(forKey: "vicinity") as! String
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            let rating = placeDict.object(forKey: "rating") as? Double ?? 0.0
                            let iconURL = placeDict.object(forKey: "icon") as! String
                            let placeID = placeDict.object(forKey: "place_id") as! String
                        }
                }
            }
        }
    }
        self.dismiss(animated: false, completion: nil)
    }
    
    //Method for slider value change detection.
    @IBAction func sliderValueChanged(_ sender: Any) {
        distanceRangeLabel.text = floor(distanceSlider.value).description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //Ignore this method. Gonna deprecate.
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

}
