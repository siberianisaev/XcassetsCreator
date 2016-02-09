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
        return (folderPath! as NSString).stringByAppendingPathComponent((folderPath! as NSString).lastPathComponent + ".xcassets")
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


    @IBAction func selectFolder(sender: AnyObject)
    {
        OpenPanel.open { [unowned self] (folders: [String]?) in
            if let folders = folders {
                for folderPath in folders {
                    self.folderPath = folderPath
                    do {
                        var files = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
                        files = files.filter() {
                            let pathExtension = ($0 as NSString).pathExtension
                            // Supported Image Formats https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIImage_Class/index.html
                            for value in ["png", "jpg", "jpeg", "tiff", "tif", "gif", "bmp", "BMPf", "ico", "cur", "xbm"] {
                                if pathExtension.caseInsensitiveCompare(value) == NSComparisonResult.OrderedSame {
                                    return true
                                }
                            }
                            return false
                        }
                        self.createAssetCataloguesWithImages(files)
                    } catch {
                        print(error)
                    }
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
            do {
                try fm.createDirectoryAtPath(assetsPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return
            }
        }
        
        self.progressIndicator.startAnimation(nil)
        
        let sorted = images.sort({
            $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedDescending
        })
        
        var assetsDict = [String: Asset]()
        for imageFileName in sorted {
            var name = (imageFileName as NSString).stringByDeletingPathExtension
            for value in ["-568h", "@2x", "@3x", "~ipad", "~iphone"] {
                name = name.stringByRemoveSubstring(value)
            }
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
        for (_, value) in assetsDict {
            value.createAsset(assetsFolderPath) // Create asset folder & contents json
            
            for imageName in value.images { // Copy images to asset
                if let folderPath = folderPath, path = value.path {
                    let oldPath = (folderPath as NSString).stringByAppendingPathComponent(imageName)
                    let newPath = (path as NSString).stringByAppendingPathComponent(imageName)
                    do {
                        try fm.copyItemAtPath(oldPath, toPath: newPath)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        
        self.progressIndicator.stopAnimation(nil)
    }
    
}

