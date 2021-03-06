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
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var autocompleteTableView: UITableView!
    
    var product: Product?
    
    // for auto-complete of category
    var existingCategories = ["DidnLoad"]
    var autocompleteCategories = [String]()
    
    // needed a set otherwise did not change when run on real iPhone 5 at least
    func setProduct(_ product: Product) {
        self.product = product
    }
    
    func setCategories(_ categories: [String]) {
        self.existingCategories = categories
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender as AnyObject? === saveButton {
            let name = searchTextField.text ?? ""
            let brand = brandTextField.text ?? ""
            let cat = catTextField.text ?? ""
            let rating = ratingControl.rating ?? 0
            let comments = commentsTextView.text ?? ""
            
            if product == nil {
                // create a new product
                product = Product(id: nil, name: name.trim(), brand: brand.trim(), category: cat.trim(), rating: rating, comments: comments)
            }
            else {
                // existing product (make sure to preserve id)
                product!.name = name.trim()
                product!.brand = brand.trim()
                product!.category = cat.trim()
                product!.rating = rating
                product!.comments = comments
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        // if Add mode, it was modal, so close modal, else navigate back
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    // MARK: Actions
    @IBAction func addNewItem(_ sender: AnyObject) {
        // TODO: NOT IMPLEMENTED YET
        let alertController = UIAlertController(title: "I Love It!", message:
            "Not implemented yet!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidProductValues()
        autocompleteTableView.isHidden = true
        if textField == searchTextField {
            navigationItem.title = textField.text
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if textField == catTextField {
            // move the autopopulate list view to just under category and same width
            let catTextFrame = self.view.convert(catTextField.frame, from:catTextField.superview)
            autocompleteTableView.frame.origin.y = catTextFrame.origin.y + catTextFrame.height
            autocompleteTableView.frame.origin.x = catTextFrame.origin.x
            autocompleteTableView.frame.size.width = catTextFrame.size.width
            
            // see if we have a match
            let substring = (catTextField.text! as NSString).replacingCharacters(in: range, with: string)
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
        saveButton.isEnabled = !anyEmpty
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
            commentsTextView.text = product.comments ?? ""
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidProductValues()
        
        // auto-complete
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Auto-complete tableview
    
    // search for match for type-ahaed (right now onlys supports the one field - cat
    func searchAutocompleteEntriesWithSubstring(_ substring: String)
    {
        autocompleteCategories.removeAll(keepingCapacity: false)
        
        for curString in existingCategories
        {
            let myString:NSString! = curString.lowercased() as NSString
            
            let substringRange : NSRange! = myString.range(of: substring.lowercased())
            
            if (substringRange.location == 0)
            {
                autocompleteCategories.append(curString)
            }
        }
        
        // show the autocomplete view if we have a match
        autocompleteTableView.isHidden = autocompleteCategories.count < 1
        autocompleteTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: autoCompleteRowIdentifier, for: indexPath) as UITableViewCell
        let index = (indexPath as NSIndexPath).row as Int
        
        cell.textLabel!.text = autocompleteCategories[index]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
        catTextField.text = selectedCell.textLabel!.text
        autocompleteTableView.isHidden = true
    }

}

