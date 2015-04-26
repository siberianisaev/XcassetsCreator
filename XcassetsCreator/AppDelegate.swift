//
//  AppDelegate.swift
//  XcassetsCreator
//
//  Created by Andrey Isaev on 26.04.15.
//  Copyright (c) 2015 Andrey Isaev. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    private var folderPath: String?
    private var assetsFolderPath: String {
        return folderPath!.stringByAppendingPathComponent(folderPath!.lastPathComponent + ".xcassets")
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


    @IBAction func selectFolder(sender: AnyObject)
    {
        OpenPanel.open { [unowned self] (folderPath: String?) in
            self.folderPath = folderPath
            
            if let folderPath = folderPath {
                var error: NSError?
                if var files = NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath, error: &error) {
                    files = files.filter() {
                        if let pathExtension = ($0 as? String)?.pathExtension {
                            // Supported Image Formats https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIImage_Class/index.html
                            for value in ["png", "jpg", "jpeg", "tiff", "tif", "gif", "bmp", "BMPf", "ico", "cur", "xbm"] {
                                if pathExtension.caseInsensitiveCompare(value) == NSComparisonResult.OrderedSame {
                                    return true
                                }
                            }
                        }
                        return false
                    }
                    self.createAssetCataloguesWithImages(files as! [String])
                } else if let error = error {
                    println(error)
                }
            }
        }
    }
    
    private func createAssetCataloguesWithImages(images: [String]) {
        if images.isEmpty {
            return
        }
        
        let assetsPath = assetsFolderPath
        let fm = NSFileManager.defaultManager()
        if false == fm.fileExistsAtPath(assetsPath) {
            var error: NSError?
            if false == fm.createDirectoryAtPath(assetsPath, withIntermediateDirectories: true, attributes: nil, error: &error) {
                if let error = error {
                    println(error)
                    return
                }
            }
        }
        
        self.progressIndicator.startAnimation(nil)
        
        var sorted = images.sorted {
            $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedDescending
        }
        
        var assetsDict = [String: Asset]()
        for imageFileName in sorted {
            var name = imageFileName.stringByDeletingPathExtension
            name = name.stringByReplacingOccurrencesOfString("@2x", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            name = name.stringByReplacingOccurrencesOfString("@3x", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            name = name.stringByReplacingOccurrencesOfString("~ipad", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            name = name.stringByReplacingOccurrencesOfString("~iphone", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
            if name.isEmpty {
                continue
            }
            
            var asset = assetsDict[name]
            if asset == nil {
                asset = Asset(name: name)
                assetsDict[name] = asset
            }
            asset!.images.append(imageFileName)
        }
        for (key, value) in assetsDict {
            value.createAsset(assetsFolderPath) // Create asset folder & contents json
            
            for imageName in value.images { // Copy images to asset
                if let oldPath = folderPath?.stringByAppendingPathComponent(imageName) {
                    if let newPath = value.path?.stringByAppendingPathComponent(imageName) {
                        var error: NSError?
                        fm.copyItemAtPath(oldPath, toPath: newPath, error: &error)
                        if let error = error {
                            println(error)
                        }
                    }
                }
            }
        }
        
        self.progressIndicator.stopAnimation(nil)
    }
    
}

