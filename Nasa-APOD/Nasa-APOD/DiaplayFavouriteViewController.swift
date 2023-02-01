//
//  DiaplayFavouriteViewController.swift
//  Nasa-APOD
//
//  Created by bhaskar kumar on 24/01/23.
//

import UIKit
import CoreData

class DiaplayFavouriteViewController: UIViewController {
    
    //creating variable of the type FavouriteDates Entity.
    var dates : FavouriteDates!
    
    
    @IBOutlet weak var DateLbl: UILabel!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var DescriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DateLbl.text = dates.favDate
        displayData()
    }
    
    //Method to display the image & description that was fetched from the Nasa API using the date passed from FavouriteViewController
    func displayData(){
        //var baseURL = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"
        var baseURL = "https://api.nasa.gov/planetary/apod?api_key=q3h8iW3ySUd8adUyDG963Qj2Mp7BKlSzSPSyYXiu"
        let dateSelected = "&date="+DateLbl.text!+"&"
        baseURL += dateSelected
        let connectionString = URL(string: baseURL)!
        
        //Creating URL session
        let task = URLSession.shared.dataTask(with: connectionString) { data,response, error in
            guard let data =  data else { return }
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let img = jsonData?["url"] as? String
            let desc = jsonData?["explanation"] as? String
            
            //Fetching Image from the url which was fetched from NASA APOD API
            guard let imageURL = URL(string: img!) else { return }
            //load image and description on ui asynchronously on the main thread
            DispatchQueue.main.async{
                guard let imageData = try? Data(contentsOf: imageURL) else { return }
                let image = UIImage(data: imageData)
                self.ImageView.image = image
                self.DescriptionText.text = desc!
            }
        }
        task.resume()
    }
    

    

}
