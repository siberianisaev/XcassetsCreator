//
//  String+Addition.swift
//  XcassetsCreator
//
//  Created by Andrey Isaev on 26.04.15.
//  Copyright (c) 2015 Andrey Isaev. All rights reserved.
//

import Foundation

extension String {

    func hasSubstring(substring: String) -> Bool {
        return self.rangeOfString(substring, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil
    }
    
    func stringByRemoveSubstring(substring: String) -> String {
        return self.stringByReplacingOccurrencesOfString(substring, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    }
    
}
