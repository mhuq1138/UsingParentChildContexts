//
//  EditViewController.swift
//  MultipleContextWithNotification
//
//  Created by Mazharul Huq on 3/5/18.
//  Copyright © 2018 Mazharul Huq. All rights reserved.
//

import UIKit
import CoreData

protocol EditViewControllerDelegate{
    func doneEditing(_ save:Bool)
}

class EditViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!

    var address:Address?
    var delegate:EditViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Here")
        print(address)
        nameField.text = address?.name
        streetField.text = address?.street
        cityField.text = address?.city
        stateField.text = address?.state
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        address?.name = nameField.text
        address?.street = streetField.text
        address?.city = cityField.text
        address?.state = stateField.text
        
        self.delegate?.doneEditing( true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.delegate?.doneEditing(false)
    }
}
