//
//  ProductTableViewController.swift
//  ILoveIt
//
//  Created by Kevin Walter on 9/8/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController,  UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    var products = [Product]()
    // TODO: make as a filter struct
    var catFilter: String?
    
    // TODO; Get from DB
    var existingCategories = ["All"]
    
    @IBOutlet weak var busyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // UDisplay an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //we will add a picker for the category search
        let catPickerView = UIPickerView()
        //pickerview tool bar
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        var items = [UIBarButtonItem]()
        //making done button
        //let doneButton = UIBarButtonItem(title: "Go", style: .Plain, target: self, action: Selector(donePressed()))
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Go", style: .Plain, target: self, action: #selector(ProductTableViewController.executeFilter))
        items.append(flexButton)
        items.append(doneButton)
        //toolbar.barStyle = UIBarStyle.Black
        toolbar.setItems(items, animated: true)
        
        
        catPickerView.delegate = self
        categoryTextField.inputAccessoryView = toolbar
        categoryTextField.inputView = catPickerView
        
        categoryTextField.delegate = self;
        
        loadServerProducts()
    }
    
    func executeFilter() {
        categoryTextField.endEditing(true)
    }
    
    func loadSampleProducts() {
        products.append(Product(id: nil, name: "test1", brand: "Brand X", category: "cat1", rating: 2)!)
        products.append(Product(id: nil, name: "test2", brand: "Brand Y", category: "cat1", rating: 8)!)
    }
    
    func loadServerProducts() {
        // show as busy
        busyIndicator.startAnimating()
        products.removeAll(keepCapacity: false)
        
        // go get the products
        let productWebService = ProductWebService()
        productWebService.getProducts(catFilter, success: {
            (products: [[String: AnyObject]]) -> Void in
            //go back into UI thread to update table
            dispatch_async(dispatch_get_main_queue()) {
                
                for product in products {
                    self.products.append(Product(id: (product["_id"] as? String)!, name: (product["name"] as? String)!.unencode(), brand: (product["brand"] as? String)!.unencode(), category: (product["category"] as? String)!, rating: (product["rating"]as? Int)!)!)
                }
                print(self.products)
                self.busyIndicator.stopAnimating()
                self.doTableRefresh()
            }
            
        })
        
        productWebService.getCategories({
            (categories: [String]) -> Void in
            //self.existingCategories.removeAll(keepCapacity: false)
            self.existingCategories = ["All"]
            for category in categories {
                self.existingCategories.append(category)
            }
            print(self.products)
        })
        
    }
    
    // refresh in main thread
    func doTableRefresh() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ProductTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ProductTableViewCell
        
        let product = products[indexPath.row]

        cell.nameLabel.text = product.brand + " - " + product.name
        cell.ratingControl.setInitRating(product.rating)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let product = products[indexPath.row]
            products.removeAtIndex(indexPath.row)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // Delete from db
            let productWebService = ProductWebService()
            productWebService.deleteProduct(product)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        print("here")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //autocompleteTableView.hidden = true
        if textField == categoryTextField {
            if let catString = categoryTextField.text {
                catFilter = catString
            }
            else {
                catFilter = nil
            }
            loadServerProducts()
        }
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return existingCategories.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return existingCategories[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedCategory = ""
        if existingCategories[row] != "All" {
            selectedCategory = existingCategories[row]
        }
        categoryTextField.text = selectedCategory
        //categoryTextField.endEditing(true)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let productDetailViewController = segue.destinationViewController as! ProductViewController
            // Get the cell that generated this segue.
            if let selectedProductCell = sender as? ProductTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedProductCell)!
                let selectedProduct = products[indexPath.row]
                productDetailViewController.setProduct(selectedProduct)
                productDetailViewController.setCategories(self.existingCategories)
            }
        }
        else if segue.identifier == "AddItem" {
        }
    }
    
    @IBAction func unwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ProductViewController, product = sourceViewController.product {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Edit an existing product
                products[selectedIndexPath.row] = product
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                // Persist
                let productWebService = ProductWebService()
                productWebService.updateProduct(product)
            }
            else {
                // Add a new product
                let newIndexPath = NSIndexPath(forRow: products.count, inSection: 0)
                products.append(product)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                // Persist
                let productWebService = ProductWebService()
                productWebService.createProduct(product)
            }
        }
    }

}
