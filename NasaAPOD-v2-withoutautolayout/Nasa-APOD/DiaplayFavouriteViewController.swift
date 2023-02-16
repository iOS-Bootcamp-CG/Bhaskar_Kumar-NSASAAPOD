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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context : NSManagedObjectContext!
    
    private var favouriteDatesObject = [FavouriteDates]()
    
    
    @IBOutlet weak var DateLbl: UILabel!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var DescriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DateLbl.text = dates.favDate
        //displayData()
        connectToDatabase()
    }
    
    /*
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
    */
    
    func connectToDatabase(){
        
        context = appDelegate.persistentContainer.viewContext
        getData()
    }
    
    func getData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteDates")
        
        request.returnsObjectsAsFaults = false
        
        do{
            let result = try context.fetch(request)
            favouriteDatesObject = try context.fetch(request) as! [FavouriteDates]
            
            //fetching data for the selected date
            for dates in result as! [NSManagedObject]{
                let myValue = dates.value(forKey: "favDate") as! String
                if myValue == DateLbl.text{
                    self.DescriptionText.text = dates.value(forKey: "descriptionText") as? String
                    let imageData = Data(base64Encoded: dates.value(forKey: "imageData") as! Data,
                                                 options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                    let image = UIImage(data: imageData)!
                    self.ImageView.image = image
                }
            }
        }catch{
            print("No Data Fetched!")
        }
    }
     
    

    

}
