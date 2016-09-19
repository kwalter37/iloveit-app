//
//  ProductTableViewController.swift
//  ILoveIt
//
//  Created by Kevin Walter on 9/8/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController {
    
    // MARK: Properties
    var products = [Product]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // UDisplay an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        loadServerProducts()
    }
    
    func loadSampleProducts() {
        products.append(Product(id: nil, name: "test1", brand: "Brand X", category: "cat1", rating: 2)!)
        products.append(Product(id: nil, name: "test2", brand: "Brand Y", category: "cat1", rating: 8)!)
    }
    
    func loadServerProducts() {
        //load up with a dummy row
        products.append(Product(id: nil, name: "loading...", brand: "", category: "", rating: 0)!)
        
        let requestURL: NSURL = NSURL(string: "http://iloveit.herokuapp.com/products")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                print(httpResponse)
                
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let products = json as? [[String: AnyObject]] {
                        self.products.removeAll()
                        for product in products {
                            self.products.append(Product(id: nil, name: (product["name"] as? String)!, brand: (product["brand"] as? String)!, category: (product["category"] as? String)!, rating: (product["rating"]as? Int)!)!)
                        }
                        print(self.products)
                        self.doTableRefresh()
                    }
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()
        
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

        cell.nameLabel.text = product.name
        cell.ratingLabel.text = String(product.rating)

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
            products.removeAtIndex(indexPath.row)
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // TODO: Persist
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
                // TODO: We will need to persist
            }
            else {
                // Add a new product
                let newIndexPath = NSIndexPath(forRow: products.count, inSection: 0)
                products.append(product)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                // TODO: We will need to persist
            }
        }
    }

}
