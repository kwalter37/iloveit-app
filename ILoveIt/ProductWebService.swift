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
    func getProducts(_ filter: String?, success: @escaping (_ products: [[String: AnyObject]]) -> Void) {
        var catFilterStr = ""
        if let catFilter = filter , !catFilter.isEmpty {
            catFilterStr += "?category=" + catFilter.encode()
        }
        let requestURL: URL = URL(string: baseUrl + "/products" + catFilterStr)!
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                print(httpResponse)
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    if let products = json as? [[String: AnyObject]] {
                        success(products)
                    }
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }) 
        
        task.resume()

    }
    
    // gets all current categories
    func getCategories(_ success: @escaping (_ categories: [String]) -> Void) {
        
        let requestURL: URL = URL(string: baseUrl + "/categories")!
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                print(httpResponse)
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    
                    if let categories = json as? [String] {
                        success(categories)
                        print(categories)
                    }
                } catch {
                    print("Error with Json: \(error)")
                }
            }
        }) 
        
        task.resume()
        
    }
    
    // MARK: CRUD
    
    // CREATE
    // TODO: Add success/fail
    func createProduct(_ product: Product /*, success: () -> Void*/) {
        let requestURL: URL = URL(string: baseUrl + "/products")!
        let productDic = convertProductToDict(product)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: productDic, options:.prettyPrinted) as Data?
            
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = serializedData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(serializedData!.count)", forHTTPHeaderField: "Content-Length")
        
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 201) {
                    print("Everyone is fine, product saved successfully.")
                    print(httpResponse)
                    
                }
                else {
                    print("crap")
                }
            }) 
        
            task.resume()
 
        }
        catch {
            print ("ooops")
        }
    }
    
    // UPDATE
    // TODO: Can at least share code with update (just diff url, method, return code, msg)
    func updateProduct(_ product: Product /*, success: () -> Void*/) {
        if product.id == nil {
            print("no id so could not update")
            return
        }
        let requestURL: URL = URL(string: baseUrl + "/products" + "/" + product.id!)!
        let productDic = convertProductToDict(product)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: productDic, options:.prettyPrinted) as Data?
            
            urlRequest.httpMethod = "PUT"
            urlRequest.httpBody = serializedData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(serializedData!.count)", forHTTPHeaderField: "Content-Length")
            
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
                (data, response, error) -> Void in
                
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 204) {
                    print("Everyone is fine, product updated successfully.")
                    print(httpResponse)
                    
                }
                else {
                    print("Oh crap...service error")
                }
            }) 
            
            task.resume()
            
        }
        catch {
            print ("ooops")
        }
    }
    
    // DELETE
    // TODO: Add success/fail
    func deleteProduct (_ product: Product) {
        // TODO: Add auth code
        let requestURL: URL = URL(string: baseUrl + "/products" + "/" + product.id!)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 204) {
                print("Everyone is fine, product deleted successfully.")
                print(httpResponse)
                
            }
            else {
                print("Oh crap...service error")
            }
        }) 
        
        task.resume()
    }

    // MARK: utilities
    
    // TODO: Maybe can make a map or something
    func convertProductToDict(_ product: Product) -> AnyObject {
        let optComments = product.comments ?? ""
        return ["name": product.name.encode(), "brand": product.brand.encode(), "category": product.category, "rating": product.rating, "comments": optComments] as AnyObject
    }

    
}
