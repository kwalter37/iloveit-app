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
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //we will add a picker for the category search
        let catPickerView = UIPickerView()
        //pickerview tool bar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        var items = [UIBarButtonItem]()
        //making done button
        //let doneButton = UIBarButtonItem(title: "Go", style: .Plain, target: self, action: Selector(donePressed()))
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Go", style: .plain, target: self, action: #selector(ProductTableViewController.executeFilter))
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
        products.append(Product(id: nil, name: "test1", brand: "Brand X", category: "cat1", rating: 2, comments: "")!)
        products.append(Product(id: nil, name: "test2", brand: "Brand Y", category: "cat1", rating: 8, comments: "")!)
    }
    
    func loadServerProducts() {
        // show as busy
        busyIndicator.startAnimating()
        products.removeAll(keepingCapacity: false)
        
        // go get the products
        let productWebService = ProductWebService()
        productWebService.getProducts(catFilter, success: {
            (products: [[String: AnyObject]]) -> Void in
            //go back into UI thread to update table
            DispatchQueue.main.async {
                
                for product in products {
                    self.products.append(Product(id: (product["_id"] as? String)!, name: (product["name"] as? String)!.unencode(), brand: (product["brand"] as? String)!.unencode(), category: (product["category"] as? String)!, rating: (product["rating"]as? Int)!, comments: (product["comments"] as? String))!)
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
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ProductTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductTableViewCell
        
        let product = products[(indexPath as NSIndexPath).row]

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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let product = products[(indexPath as NSIndexPath).row]
            products.remove(at: (indexPath as NSIndexPath).row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            // Delete from db
            let productWebService = ProductWebService()
            productWebService.deleteProduct(product)
            
        } else if editingStyle == .insert {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        print("here")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return existingCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return existingCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedCategory = ""
        if existingCategories[row] != "All" {
            selectedCategory = existingCategories[row]
        }
        categoryTextField.text = selectedCategory
        //categoryTextField.endEditing(true)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let productDetailViewController = segue.destination as! ProductViewController
            // Get the cell that generated this segue.
            if let selectedProductCell = sender as? ProductTableViewCell {
                let indexPath = tableView.indexPath(for: selectedProductCell)!
                let selectedProduct = products[(indexPath as NSIndexPath).row]
                productDetailViewController.setProduct(selectedProduct)
                productDetailViewController.setCategories(self.existingCategories)
            }
        }
        else if segue.identifier == "AddItem" {
            // we have a modal so a nav controller sits between us and the view controller
            let productDetailNavController = segue.destination as! UINavigationController
            let productDetailViewController = productDetailNavController.topViewController as! ProductViewController
            productDetailViewController.setCategories(self.existingCategories)
        }
    }
    
    @IBAction func unwindToProductList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ProductViewController, let product = sourceViewController.product {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Edit an existing product
                products[(selectedIndexPath as NSIndexPath).row] = product
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                // Persist
                let productWebService = ProductWebService()
                productWebService.updateProduct(product)
            }
            else {
                // Add a new product
                let newIndexPath = IndexPath(row: products.count, section: 0)
                products.append(product)
                tableView.insertRows(at: [newIndexPath], with: .bottom)
                // Persist
                let productWebService = ProductWebService()
                productWebService.createProduct(product)
            }
        }
    }

}
