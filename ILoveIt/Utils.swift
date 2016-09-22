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
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    func unencode() -> String {
        return self.stringByRemovingPercentEncoding!
    }
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}