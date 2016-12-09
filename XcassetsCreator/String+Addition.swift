//
//  String+Addition.swift
//  XcassetsCreator
//
//  Created by Andrey Isaev on 26.04.15.
//  Copyright (c) 2015 Andrey Isaev. All rights reserved.
//

import Foundation

extension String {

    func hasSubstring(_ substring: String) -> Bool {
        return self.range(of: substring, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil
    }
    
    func stringByRemoveSubstring(_ substring: String) -> String {
        return self.replacingOccurrences(of: substring, with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
    }
    
}
