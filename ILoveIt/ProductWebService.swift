//
//  ProductWebService.swift
//  ILoveIt
//
//  Created by Kevin Walter on 9/19/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import Foundation

class ProductWebService {
    
    let baseUrl = "http://iloveit.herokuapp.com"
    
    // MARK: List Related
    
    // TODO: Add filters
    func getProducts(filter: String?, success: (products: [[String: AnyObject]]) -> Void) {
        var catFilterStr = ""
        if let catFilter = filter where !catFilter.isEmpty {
            catFilterStr += "?category=" + catFilter.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        }
        let requestURL: NSURL = NSURL(string: baseUrl + "/products" + catFilterStr)!
        
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
                        success(products: products)
                    }
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        
        task.resume()

    }
    
    // MARK: CRUD
    
    // CREATE
    // TODO: Add success/fail
    func createProduct(product: Product /*, success: () -> Void*/) {
        let requestURL: NSURL = NSURL(string: baseUrl + "/products")!
        let productDic = convertProductToDict(product)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        do {
            let serializedData = try NSJSONSerialization.dataWithJSONObject(productDic, options:.PrettyPrinted) as NSData?
            
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = serializedData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(serializedData!.length)", forHTTPHeaderField: "Content-Length")
        
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) -> Void in
                
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 201) {
                    print("Everyone is fine, product saved successfully.")
                    print(httpResponse)
                    
                }
                else {
                    print("crap")
                }
            }
        
            task.resume()
 
        }
        catch {
            print ("ooops")
        }
    }
    
    // UPDATE
    // TODO: Can at least share code with update (just diff url, method, return code, msg)
    func updateProduct(product: Product /*, success: () -> Void*/) {
        if product.id == nil {
            print("no id so could not update")
            return
        }
        let requestURL: NSURL = NSURL(string: baseUrl + "/products" + "/" + product.id!)!
        let productDic = convertProductToDict(product)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        do {
            let serializedData = try NSJSONSerialization.dataWithJSONObject(productDic, options:.PrettyPrinted) as NSData?
            
            urlRequest.HTTPMethod = "PUT"
            urlRequest.HTTPBody = serializedData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(serializedData!.length)", forHTTPHeaderField: "Content-Length")
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) -> Void in
                
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 204) {
                    print("Everyone is fine, product updated successfully.")
                    print(httpResponse)
                    
                }
                else {
                    print("Oh crap...service error")
                }
            }
            
            task.resume()
            
        }
        catch {
            print ("ooops")
        }
    }
    
    // DELETE
    // TODO: Add success/fail
    func deleteProduct (product: Product) {
        // TODO: Add auth code
        let requestURL: NSURL = NSURL(string: baseUrl + "/products" + "/" + product.id!)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        urlRequest.HTTPMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 204) {
                print("Everyone is fine, product deleted successfully.")
                print(httpResponse)
                
            }
            else {
                print("Oh crap...service error")
            }
        }
        
        task.resume()
    }

    // MARK: utilities
    
    // TODO: Maybe can make a map or something
    func convertProductToDict(product: Product) -> AnyObject {
        return ["name": product.name, "brand": product.brand, "category": product.category, "rating": product.rating]
    }

    
}
