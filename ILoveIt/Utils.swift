//
//  Utils.swift
//  ILoveIt
//
//  Created by Kevin Walter on 9/22/16.
//  Copyright © 2016 Kevin Walter. All rights reserved.
//

import Foundation


extension String
{
    func encode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    func unencode() -> String {
        return self.removingPercentEncoding!
    }
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
