//
//  ILoveItTests.swift
//  ILoveItTests
//
//  Created by Kevin Walter on 9/6/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import XCTest
@testable import ILoveIt

class ILoveItTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testProductInit() {
        let potentialProduct = Product(id: nil, name: "YuckyMush", brand: "Y", category: "Pasta", rating: 1)
        XCTAssertNotNil(potentialProduct)
        
        let emptyName = Product(id: nil, name: "", brand: "Ha", category: "Pasta", rating: 1)
        XCTAssertNil(emptyName)
        
        let badRating = Product(id: nil, name: "", brand: "blah", category: "Pasta", rating: -1)
        XCTAssertNil(badRating)
    }
    
}
