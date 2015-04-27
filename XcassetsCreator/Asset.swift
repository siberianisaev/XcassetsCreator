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
                if image.hasSubstring(value) {
                    return false
                }
            }
        }
        return true
    }
    
    private var hasPhonePostfix: Bool {
        for image in images {
            if image.hasSubstring("~iphone") {
                return true
            }
        }
        return false
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
                if image.hasSubstring("@3x") {
                    names[3] = image
                } else if image.hasSubstring("@2x") {
                    names[2] = image
                } else {
                    names[1] = image
                }
            }
            
            var imagesArray = [[String: String]]()
            for index in 1...3 {
                var dic = ["idiom": "universal", "scale": "\(index)x"]
                if let name = names[index] {
                    if false == name.isEmpty {
                        dic["filename"] = name
                    }
                }
                imagesArray.append(dic)
            }
            dictionary["images"] = imagesArray
        } else {
            var namesIphone = [Int: String]()
            var namesIpad = [Int: String]()
            let hasPhonePostfix = self.hasPhonePostfix
            var imagesArray = [[String: String]]()
            
            for image in images {
                if image.hasSubstring("-568h") {
                    imagesArray.append(["idiom": "iphone", "subtype": "retina4", "scale": "2x", "filename" : image])
                } else if hasPhonePostfix {
                    if image.hasSubstring("~iphone") {
                        if image.hasSubstring("@3x") {
                            namesIphone[3] = image
                        } else if image.hasSubstring("@2x") {
                            namesIphone[2] = image
                        } else {
                            namesIphone[1] = image
                        }
                    } else {
                        if image.hasSubstring("@2x") {
                            namesIpad[2] = image
                        } else {
                            namesIpad[1] = image
                        }
                    }
                } else {
                    if image.hasSubstring("~ipad") {
                        if image.hasSubstring("@2x") {
                            namesIpad[2] = image
                        } else {
                            namesIpad[1] = image
                        }
                    } else {
                        if image.hasSubstring("@3x") {
                            namesIphone[3] = image
                        } else if image.hasSubstring("@2x") {
                            namesIphone[2] = image
                        } else {
                            namesIphone[1] = image
                        }
                    }
                }
            }
            
            for index in 1...2 {
                var dic = ["idiom": "ipad", "scale": "\(index)x"]
                if let name = namesIpad[index] {
                    if false == name.isEmpty {
                        dic["filename"] = name
                    }
                }
                imagesArray.append(dic)
            }
            for index in 1...3 {
                var dic = ["idiom": "iphone", "scale": "\(index)x"]
                if let name = namesIphone[index] {
                    if false == name.isEmpty {
                        dic["filename"] = name
                    }
                }
                imagesArray.append(dic)
            }
            
            dictionary["images"] = imagesArray
        }
        
        dictionary["info"] = ["version": 1, "author": "xcode"]
        return dictionary
    }
    
}
