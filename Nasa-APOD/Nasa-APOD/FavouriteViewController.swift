//
//  FavouriteViewController.swift
//  Nasa-APOD
//
//  Created by bhaskar kumar on 23/01/23.
//

import UIKit
import CoreData

class FavouriteViewController: UIViewController, UITableViewDelegate , UITableViewDataSource{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context : NSManagedObjectContext!
    
    //refreshing data of table view on slide down
    let refreshControl = UIRefreshControl()
    
    //creating Table View
    let TabView : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    //creating an object of the table FavouriteDates
    private var favouriteDatesObject = [FavouriteDates]()
    
    //return number of rows that needs to be created on the Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteDatesObject.count
    }
    
    //Return number of cells that needs to be created on the Table View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = favouriteDatesObject[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data.favDate
        return cell
    }
    
    //It navigates to the connected segue on clicking any row in the Table View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DisplayFavDateDetails", sender: self)
    }
    
    //Sends the value of the clicked row to next controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DiaplayFavouriteViewController {
            destination.dates = favouriteDatesObject[(TabView.indexPathForSelectedRow?.row)!  ]
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(TabView)
        TabView.delegate = self
        TabView.dataSource = self
        TabView.frame = view.bounds
        connectToDatabase()
        TabView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTabView), for: .valueChanged)
    }
    
    //Thisfunction is used to refresh the Table View
    @objc func refreshTabView(){
        connectToDatabase()
        refreshControl.endRefreshing()
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.TabView.reloadData()
        }
    }
    */
    
    //Making connection to the database.
    func connectToDatabase(){
        
        context = appDelegate.persistentContainer.viewContext
        getDates()
    }
    
    //Used to get all the Dates from FavouriteDates Entity.
    func getDates(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteDates")
        
        request.returnsObjectsAsFaults = false
        
        do{
            let result = try context.fetch(request)
            favouriteDatesObject = try context.fetch(request) as! [FavouriteDates]
            
            //Reloading Table View on main thread.
            DispatchQueue.main.async {
                self.TabView.reloadData()
            }
            
            //for developer reference
            for dates in result as! [NSManagedObject]{
                let myValue = dates.value(forKey: "favDate") as! String
                print("Fetched Date is " + myValue)
            }
        }catch{
            print("No Data Fetched!")
        }
    }
}
