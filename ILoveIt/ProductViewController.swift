//
//  ViewController.swift
//  ILoveIt
//
//  Created by Kevin Walter on 9/6/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var catTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingControl: RatingControl!
    
    var product: Product?
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

