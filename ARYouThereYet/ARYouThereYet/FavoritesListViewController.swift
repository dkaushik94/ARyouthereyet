//
//  FavoritesListViewController.swift
//  ARYouThereYet
//
//  Created by Sandeep Joshi on 12/2/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class FavoritesListViewController: UITableViewController, CLLocationManagerDelegate{

    var favoritePlaces : [Place]?
    
    let locationManager = CLLocationManager()
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        
        tableView.separatorStyle = .none
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    

    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.favoritePlaces?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("FavoriteTableViewCell", owner: self, options: nil)?.first as! FavoriteTableViewCell
        cell.placeName.text = self.favoritePlaces?[indexPath.row].name
        cell.placeAddress.text = self.favoritePlaces?[indexPath.row].address
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61.5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = self.favoritePlaces![indexPath.row]
        
        let nav = storyBoard.instantiateViewController(withIdentifier: "NavViewController") as! NavViewController
        nav.currentLocation = locationManager.location!.coordinate
        let destinationLocation = CLLocationCoordinate2D(latitude: (selectedPlace.lattitude), longitude: (selectedPlace.longitude))
        nav.destinationLocationCustom = destinationLocation
        self.present(nav, animated: true, completion: nil)
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



class FavoritePlace {
    
    var placeName: String
    var placeAddress : String
    
    init(name: String, address: String) {
        placeName = name
        placeAddress = address
    }
}
