//
//  Asset.swift
//  XcassetsCreator
//
//  Created by Andrey Isaev on 26.04.15.
//  Copyright (c) 2015 Andrey Isaev. All rights reserved.
//

import Foundation

class Asset {
    
    var name: String?
    var path: String?
    var images = [String]()
    
    private var isUniversal: Bool {
        for image in images {
            for value in ["~ipad", "~iphone"] {
                if image.rangeOfString(value, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                    return false
                }
            }
        }
        return true
    }
    
    init(name: String) {
        self.name = name
    }
    
    func createAsset(folderPath: String) {
        if let name = name {
            path = folderPath.stringByAppendingPathComponent(name + ".imageset")
            let fm = NSFileManager.defaultManager()
            if false == fm.fileExistsAtPath(path!) {
                var error: NSError?
                if false == fm.createDirectoryAtPath(path!, withIntermediateDirectories: false, attributes: nil, error: &error) {
                    if let error = error {
                        println(error)
                        return
                    }
                }
            }
            
            let jsonPath = path!.stringByAppendingPathComponent("Contents.json")
            if let stream = NSOutputStream(toFileAtPath: jsonPath, append: false) {
                stream.open()
                var error: NSError?
                let json: AnyObject = createContentsJSON() as AnyObject
                NSJSONSerialization.writeJSONObject(json, toStream: stream, options: nil, error: &error)
                stream.close()
            }
        }
    }
    
    private func createContentsJSON() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        
        dictionary["images"] = [[String: String]]()
        if isUniversal {
            var names = [Int: String]()
            for image in images {
                if image.rangeOfString("@3x", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                    names[3] = image
                } else if image.rangeOfString("@2x", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                    names[2] = image
                } else {
                    names[1] = image
                }
            }
            
            var imagesArray = [[String: String]]()
            for index in 1...3 {
                var name = names[index]
                if name == nil {
                    name = ""
                }
                imagesArray.append(["idiom": "universal", "scale": "\(index)x", "filename" : name!])
            }
            dictionary["images"] = imagesArray
        } else {
            var namesIphone = [Int: String]()
            var namesIpad = [Int: String]()
            for image in images {
                if image.rangeOfString("~ipad", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                    if image.rangeOfString("@2x", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                        namesIpad[2] = image
                    } else {
                        namesIpad[1] = image
                    }
                } else {
                    if image.rangeOfString("@3x", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                        namesIphone[3] = image
                    } else if image.rangeOfString("@2x", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil {
                        namesIphone[2] = image
                    } else {
                        namesIphone[1] = image
                    }
                }
            }
            
            var imagesArray = [[String: String]]()
            for index in 1...2 {
                var name = namesIpad[index]
                if name == nil {
                    name = ""
                }
                imagesArray.append(["idiom": "ipad", "scale": "\(index)x", "filename" : name!])
            }
            for index in 1...3 {
                var name = namesIphone[index]
                if name == nil {
                    name = ""
                }
                imagesArray.append(["idiom": "iphone", "scale": "\(index)x", "filename" : name!])
            }
            dictionary["images"] = imagesArray
        }
        
        dictionary["info"] = ["version": 1, "author": "xcode"]
        return dictionary
    }
    
}
