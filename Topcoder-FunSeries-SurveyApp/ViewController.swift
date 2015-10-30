//
//  ViewController.swift
//  Topcoder-FunSeries-SurveyApp
//
//  Created by Sugam Kalra on 29/10/15.
//  Copyright © 2015 Sugam Kalra. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate {
    
    var dataArray:NSArray!
    var plistPath:String!
    var tableData=[String]()
    
    var json: JSON?
    
    var data = [String]()
    var filtered = [String]()
    
    var prevSearchText: String? = ""
    
    @IBOutlet var SurveyTable: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    // For Core Data Implementation
    
    let managedObjectContext:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    let managedObjectModel:NSManagedObjectModel = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectModel
    
    let arrSurveys = NSMutableArray()
    var arrSurveyData = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SurveyTable.delegate=self;
        SurveyTable.dataSource=self;
        
        let gesture = UITapGestureRecognizer(target: self, action: "tapView:")
        view.addGestureRecognizer(gesture)
        
        // Condition to check if survey recors exists in database or not
        
        self.dataArray = self.retrieveSurveyData()
        
        print(self.dataArray)
        
        if self.dataArray.count > 0
        {
            print("Survey Records Exists in Database")
        }
        else
        {
            loadData()
        }
        
        
    }
    
    func loadData() {
        
        let url = NSURL(string: "http://www.mocky.io/v2/560920cc9665b96e1e69bb46")!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let json = JSON(data: data)
                
                if let array = json.array {
                    
                    for json in array
                    {
                        
                        // Saving in Core Data
                        
                        let objSurvey:Survey!
                        
                        objSurvey = NSEntityDescription.insertNewObjectForEntityForName("Survey", inManagedObjectContext: self.managedObjectContext) as! Survey
                        
                        
                        if let id = json["id"].int
                        {
                            let x:Int = id
                            
                            let myIdString = String(x)
                            
                            objSurvey.id = myIdString
                            
                            
                        }
                        
                        if let title = json["title"].string
                        {
                            objSurvey.title = title
                        }
                        
                        if let description = json["description"].string
                        {
                            
                            objSurvey.descriptionText = description
                        }
                        
                        objSurvey.isRecordDeleted = "0"
                        
                        
                        do {
                            try self.managedObjectContext.save()
                        } catch _ {
                        }
                        
                        
                    }
                }
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    // To Retrieve Survey Records
                    
                    self.retrieveSurveyData()
                    
                })
            }
        }
        
        task.resume()
        
    }

    
    func tapView(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        filterData()
    }
    
    func tableView(SurveyTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filtered.count
    }
    
    func tableView(SurveyTable: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell:UITableViewCell = SurveyTable.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        cell.textLabel?.text = self.filtered[indexPath.row]
        
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            // Modify the row from the data source
            let objSurvey:Survey = self.arrSurveys[indexPath.row] as! Survey
            
            objSurvey.isRecordDeleted = "1";
            
            // To Delete Survey Object
            //managedObjectContext.deleteObject(objSurvey)
            
            
            do {
                try managedObjectContext.save()
            } catch _ {
            }
            
            self.retrieveSurveyData()
            
        }
        else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    
    // Method to retrive survey records from core data
    
    func retrieveSurveyData() -> NSArray
    {
        let strIsRecordDeleted = "0"
        
        let predicate = NSPredicate(format: "isRecordDeleted == %@", strIsRecordDeleted)
        
        let fetchRequest = NSFetchRequest(entityName: "Survey")
        
        fetchRequest.predicate = predicate
        
        let survey:Array<Survey>? = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Survey]
        
        print(survey)
        
        self.data.removeAll()
        
        self.filtered.removeAll()
        
        self.arrSurveys.removeAllObjects()
        
        self.arrSurveys.addObjectsFromArray(survey!)
        
        let arrSurvey = NSMutableArray()
        
        for objSurvey in survey!
        {
            
            let dicSurvey = NSMutableDictionary()
            
            print(objSurvey.title)
            
            dicSurvey.setValue(objSurvey.title, forKey:"title")
            
            arrSurvey.addObject(dicSurvey);
            
            self.data.append(objSurvey.title!)
            
            
        }
        
        print(arrSurvey);
        
        
        self.arrSurveyData.removeAllObjects()
        
        self.arrSurveyData = arrSurvey;
        
        print(arrSurveyData)
        
        self.filtered = data
        
        
        self.SurveyTable.reloadData()
        
        
        return self.arrSurveyData
        

    }

    
    
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filterData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        print("canceled")
        searchBar.resignFirstResponder()
    }
    
    func filterData() {
        if prevSearchText == searchBar.text {
            return
        }
        
        if let text = searchBar.text where text != "" {
            prevSearchText = text
            filtered.removeAll()
            filtered = data.filter {
                return $0.lowercaseString.rangeOfString(text.lowercaseString) != nil
            }
        } else {
            prevSearchText = ""
            filtered = data
        }
        
        SurveyTable.reloadData()
    }
}



