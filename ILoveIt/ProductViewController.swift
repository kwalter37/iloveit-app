//
//  ViewController.swift
//  ILoveIt
//
//  Created by Kevin Walter on 9/6/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var catTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var autocompleteTableView: UITableView!
    
    var product: Product?
    
    // for auto-complete of category
    var existingCategories = ["Pasta", "Pasta Sauce", "Crackers"]
    var autocompleteCategories = [String]()
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender === saveButton {
            let name = searchTextField.text ?? ""
            let brand = brandTextField.text ?? ""
            let cat = catTextField.text ?? ""
            let rating = ratingControl.rating ?? 0

            product = Product(id: nil, name: name, brand: brand, category: cat, rating: rating)
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        // if Add mode, it was modal, so close modal, else navigate back
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Actions
    @IBAction func addNewItem(sender: AnyObject) {
        // TODO: NOT IMPLEMENTED YET
        let alertController = UIAlertController(title: "I Love It!", message:
            "Not implemented yet!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidProductValues()
        navigationItem.title = textField.text
        autocompleteTableView.hidden = true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        if textField == catTextField {
            // move the autopopulate list view to just under category and same width
            let catTextFrame = self.view.convertRect(catTextField.frame, fromView:catTextField.superview)
            autocompleteTableView.frame.origin.y = catTextFrame.origin.y + catTextFrame.height
            autocompleteTableView.frame.origin.x = catTextFrame.origin.x
            autocompleteTableView.frame.size.width = catTextFrame.size.width
            
            // see if we have a match
            let substring = (catTextField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            searchAutocompleteEntriesWithSubstring(substring)
        }
        return true     // not sure about this - could be false
    }
    
    func checkValidProductValues() {
        // Disable the Save button if the text field is empty.
        let name = searchTextField.text ?? ""
        let brand = brandTextField.text ?? ""
        let cat = catTextField.text ?? ""
        
        let anyEmpty = name.isEmpty || brand.isEmpty || cat.isEmpty
        saveButton.enabled = !anyEmpty
    }
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self;
        brandTextField.delegate = self;
        catTextField.delegate = self;
        
        if let product = product {
            navigationItem.title = product.name
            searchTextField.text   = product.name
            brandTextField.text = product.brand
            catTextField.text = product.category
            ratingControl.rating = product.rating
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidProductValues()
        
        // auto-complete
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Auto-complete tableview
    
    // search for match for type-ahaed (right now onlys supports the one field - cat
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autocompleteCategories.removeAll(keepCapacity: false)
        
        for curString in existingCategories
        {
            let myString:NSString! = curString.lowercaseString as NSString
            
            let substringRange : NSRange! = myString.rangeOfString(substring.lowercaseString)
            
            if (substringRange.location == 0)
            {
                autocompleteCategories.append(curString)
            }
        }
        
        // show the autocomplete view if we have a match
        autocompleteTableView.hidden = autocompleteCategories.count < 1
        autocompleteTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteCategories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier, forIndexPath: indexPath) as UITableViewCell
        let index = indexPath.row as Int
        
        cell.textLabel!.text = autocompleteCategories[index]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        catTextField.text = selectedCell.textLabel!.text
        autocompleteTableView.hidden = true
    }

}

