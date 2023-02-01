//
//  ViewController.swift
//  Nasa-APOD
//
//  Created by bhaskar kumar on 23/01/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context : NSManagedObjectContext!
    
    @IBAction func AddToFavouriteBtn(_ sender: Any) {
        //condition that checks if the button Add To Favourite button is pressed after selecting any date.
        if TxtDatePicker.text == ""{
            print("Unknown date")
            
            //creating an alert box
            var dialogMessage = UIAlertController(title: "WARNING", message: "Please Choose A Date!", preferredStyle: .alert)
            
            //creating ok button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                print("Ok button pressed!")
            })
            
            //adding ok button
            dialogMessage.addAction(ok)
            
            //display alert box to the user.
            self.present(dialogMessage, animated: true, completion: nil)
        }
        else{
            //making connection to the database
            connectToDatabase()
            
            //creating an alert
            var dialogMessage = UIAlertController(title: "SUCCESS!", message: "Added To Favourites!", preferredStyle: .alert)
            
            //creating ok button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                print("Ok button pressed!")
            })
            
            //adding ok button
            dialogMessage.addAction(ok)
            
            //display alert box to the user.
            self.present(dialogMessage, animated: true, completion: nil)
            //super.viewDidLoad()
        }
    }
    @IBOutlet weak var DescriptionText: UITextView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var TxtDatePicker: UITextField!
    
    //creating an object of UIDatePicker()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createDatePicker()
        
    }

    
    //Function to create a DatePicker
    func createDatePicker() {
        //creating tool bar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
           
        //bar button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
             toolbar.setItems([doneBtn], animated: true)
            
        //asign toolbar
        TxtDatePicker.inputAccessoryView = toolbar
            
        //assigning datepicker to the text field
        TxtDatePicker.inputView = datePicker
        
        //setting maximum date that can be selected should not be greater than current date.
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value:0, to: Date())
        
        //setting minimum date that can be selected should not be less than 30 years from current date
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -30, to: Date())
        
        //making sure that the date picker shows only date, not date and time both
        datePicker.datePickerMode = .date
        
        //setting date picker style as wheel
        datePicker.preferredDatePickerStyle = .wheels
    }
    
    //Function will be called when Done button on Date Picker will be pressed.
    @objc func donePressed(){
        //formatting the date in yyyy-MM-dd format and showing on the text field
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        TxtDatePicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        
        //creating url to fetch the data from the API
        //var baseURL = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"
        var baseURL = "https://api.nasa.gov/planetary/apod?api_key=q3h8iW3ySUd8adUyDG963Qj2Mp7BKlSzSPSyYXiu"
        let dateSelected = "&date="+formatter.string(from: datePicker.date)+"&"
        baseURL += dateSelected
        let connectionString = URL(string: baseURL)!
        
        //Creating URL session
        let task = URLSession.shared.dataTask(with: connectionString) { data,response, error in
            guard let data =  data else { return }
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let img = jsonData?["url"] as? String
            let desc = jsonData?["explanation"] as? String
            
            if img != nil{
                guard let imageURL = URL(string: img!) else {
                    return
                }
                //load image and description on ui asynchronously on the main thread
                DispatchQueue.main.async{
                    guard let imageData = try? Data(contentsOf: imageURL) else { return }
                    let image = UIImage(data: imageData)
                    self.ImageView.image = image
                    self.DescriptionText.text = desc!
                }
            }
            else{
                DispatchQueue.main.async{
                    //creating an alert box
                    var dialogMessage = UIAlertController(title: "ALERT", message: "No Image Available For The Date Chosen!", preferredStyle: .alert)
                    
                    //creating ok button with action handler
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        print("Ok button pressed!")
                    })
                    
                    //adding ok button
                    dialogMessage.addAction(ok)
                    
                    //display alert box to the user.
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    //Making connection to the database.
    func connectToDatabase(){
        context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FavouriteDates", in: context)
        let favDate = NSManagedObject(entity: entity!, insertInto: context)
        saveDate(Date : favDate)
    }
    
    //Saving Date in the FavouriteDates Entity.
    func saveDate(Date : NSManagedObject){
        let dateStr = TxtDatePicker.text
        Date.setValue(dateStr, forKey: "favDate")
        print("stroring data!")
        do{
            try context.save()
            print("Data Saved Successfully!")
        } catch{
            print("Date Could Not Be Saved!")
        }
    }
    
}

