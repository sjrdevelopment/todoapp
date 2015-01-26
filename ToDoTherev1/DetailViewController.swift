//
//  DetailViewController.swift
//  ToDoTherev1
//
//  Created by robinsos on 23/01/2015.
//  Copyright (c) 2015 robinsos. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var listTitleLabel: UINavigationItem!

    @IBOutlet weak var tabView: UITableView!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            println("You have selected a list")
            self.configureView()
        }
    }
    
    var listItems = []

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            
            println(detail.valueForKey("listName")?.description)
            println("OBJECT ID: \(detail.objectID.description)")
            
            listTitleLabel.title = detail.valueForKey("listName")!.description
            println("Title description: \(listTitleLabel.description)")
        }
    }
    
    func addNewListItem(title: String) {
        
        var newListItem = NSEntityDescription.insertNewObjectForEntityForName("ListItems", inManagedObjectContext: manObjectContext!) as NSManagedObject
        newListItem.setValue(self.detailItem?.objectID.description, forKey: "listID")
        newListItem.setValue(NSDate(), forKey: "timestamp")
        newListItem.setValue(title, forKey: "title")
        println("old count is \(listItems.count)")
        //update count?
        fetchLogFromDB()
        
        let newListItemIndex = listItems.count
        // Create an NSIndexPath from the newItemIndex
        let newListItemIndexPath = NSIndexPath(forRow: newListItemIndex, inSection: 0)
    
        println("new count is \(newListItemIndex)")
        println(newListItemIndexPath)
        
        // Animate in the insertion of this row
        
        self.tabView.reloadData()
        save()
    }
    
    func cancelNewItem() {
        println("cancelling blank item")
    }
    
    @IBAction func handlePopup(sender: AnyObject) {
        
        let addItemAlertViewTag = 0
        let addItemTextAlertViewTag = 1
        
        var stringPlaceholder = "this is placeholder"
        
        var titlePrompt = UIAlertController(title: "Enter List Title",
            message: nil,
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Title"
        }
        
        titlePrompt.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler: { (action) -> Void in
                if let textField = titleTextField {
                    if(countElements(textField.text) > 0) {
                        
                        println(textField.text)
                        self.addNewListItem(textField.text)
                    } else {
                        self.cancelNewItem()
                    }
                    
                }
        }))
        
        titlePrompt.addAction(UIAlertAction(title: "Cancel",
            style: .Cancel,
            handler: { (action) -> Void in
                self.cancelNewItem()
        }))
        
        
        self.presentViewController(titlePrompt,
            animated: true,
            completion: nil)
        
    }

    
    
    
    
    
    // Table stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // reuse tableView prototype cell
        var cell = tableView.dequeueReusableCellWithIdentifier("listItemCell", forIndexPath: indexPath) as UITableViewCell
        
        //cell.textLabel?.text = "Hello \(indexPath.row)"
        var titleOfListItem = listItems[indexPath.row].valueForKey("title") as String
        cell.textLabel?.text = "\(titleOfListItem) at \(indexPath.row)"
        return cell
    }
    
    // Setup here for handling deletion
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            var listItemToDelete = listItems[indexPath.row]
            
            // Delete it from the managedObjectContext
            manObjectContext?.deleteObject(listItemToDelete as NSManagedObject)
            
            // Refresh the table view to indicate that it's deleted
            self.fetchLogFromDB()
            
            // Tell the table view to animate out that row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            save()
        }
    }

    
    
    
    // Load data for this list
    
    
    lazy var manObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let manObjectContext = appDelegate.managedObjectContext {
            return manObjectContext
        }
        else {
            return nil
        }
        }()

    
    func fetchLogFromDB() {
        
       
        
        let fetchRequest = NSFetchRequest(entityName: "ListItems")
        
        // predicate - this list only
        fetchRequest.predicate = NSPredicate(format:"listID == '\(self.detailItem!.objectID.description as String)'")
        
        // sort descriptor
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = manObjectContext!.executeFetchRequest(fetchRequest, error: nil) {
            
            println("---------------")
            
            println(fetchResults)
            
            listItems = fetchResults
            println("from fetch count is \(listItems.count)")
        }
    }
    
    // make data persist
    func save() {
        var error : NSError?
        if(manObjectContext!.save(&error) ) {
            println(error?.localizedDescription)
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        fetchLogFromDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

