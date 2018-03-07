//
//  ListViewController.swift
//  MultipleContextWithNotification
//
//  Created by Mazharul Huq on 3/5/18.
//  Copyright © 2018 Mazharul Huq. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    
    var coreDataStack = CoreDataStack(modelName: "AddressBook")
    var childContext:NSManagedObjectContext?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Address> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
        
        // Add Sort Descriptors
        let stateSort = NSSortDescriptor(key: "state", ascending: true)
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [stateSort,nameSort]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController<Address>(fetchRequest: fetchRequest, managedObjectContext: self.coreDataStack.managedContext, sectionNameKeyPath: "state", cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.childContext?.parent = self.coreDataStack.managedContext

        do {
            try fetchedResultsController.performFetch()
        }
        catch{ let nserror = error as NSError
            print("Cannot perform fetch \(nserror.localizedDescription)")
        }
    }

    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let address = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = address.name
        var streetString = ""
        var cityString = ""
        var stateString = ""
        if let street = address.street{
            streetString = street
        }
        if let city = address.city{
            cityString = city
        }
        if let state = address.state{
            stateString = state
            
        }
        cell.detailTextLabel?.text = streetString + " " + cityString + " " + stateString
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else
        {
            return 0
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections
            else
        {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections
            else
        {
            return ""
        }
        let sectionInfo = sections[section]
        return sectionInfo.name
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let address = self.fetchedResultsController.object(at: indexPath)
            self.fetchedResultsController.managedObjectContext .delete(address)
            do {
                try self.fetchedResultsController.managedObjectContext.save()
            } catch let error as NSError {
                print("Unable to delete record, Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nvc = segue.destination as? UINavigationController,
            let dvc = nvc.topViewController as? EditViewController else{
            print("Storyboard misconfigured")
            return
       }
    
       dvc.delegate = self
    
       if segue.identifier == "edit"{
           guard let indexPath = tableView.indexPathForSelectedRow else{
                print("No index path found")
               return
           }
           dvc.address = fetchedResultsController.object(at: indexPath)
       }
       if segue.identifier == "add"{
            guard let context = self.childContext else{
               return
           }
           dvc.address = Address(context: context)
       }
    }
}

extension ListViewController:EditViewControllerDelegate{
    
    func doneEditing(_ save:Bool){
        guard let context = self.childContext else{
            print("Unable to get child context")
            return
        }
        guard save,
            context.hasChanges else {
                dismiss(animated: true)
                return
        }
        context.perform {
            //Saves child context to parent context
            do {
                try context.save()
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
        //Saves parent context to store
        self.coreDataStack.saveContext()
        dismiss(animated: true)
    }
}

extension ListViewController:NSFetchedResultsControllerDelegate{
    //NSFetchedResultsController Delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!],with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!],with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)as UITableViewCell!
            configureCell(cell!, indexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!],with: .automatic)
            tableView.insertRows(at: [newIndexPath!],with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet,with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet,with: .automatic)
        default :
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
