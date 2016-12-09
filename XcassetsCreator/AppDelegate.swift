//
//  AppDelegate.swift
//  XcassetsCreator
//
//  Created by Andrey Isaev on 26.04.15.
//  Copyright (c) 2015 Andrey Isaev. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    fileprivate var folderPath: String?
    fileprivate var assetsFolderPath: String {
        return (folderPath! as NSString).appendingPathComponent((folderPath! as NSString).lastPathComponent + ".xcassets")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    @IBAction func selectFolder(_ sender: AnyObject)
    {
        OpenPanel.open { [unowned self] (folders: [String]?) in
            if let folders = folders {
                for folderPath in folders {
                    self.folderPath = folderPath
                    do {
                        var files = try FileManager.default.contentsOfDirectory(atPath: folderPath)
                        files = files.filter() {
                            let pathExtension = ($0 as NSString).pathExtension
                            // Supported Image Formats https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIImage_Class/index.html
                            for value in ["png", "jpg", "jpeg", "tiff", "tif", "gif", "bmp", "BMPf", "ico", "cur", "xbm"] {
                                if pathExtension.caseInsensitiveCompare(value) == ComparisonResult.orderedSame {
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
    
    fileprivate func createAssetCataloguesWithImages(_ images: [String]) {
        if images.isEmpty {
            return
        }
        
        let assetsPath = assetsFolderPath
        let fm = FileManager.default
        if false == fm.fileExists(atPath: assetsPath) {
            do {
                try fm.createDirectory(atPath: assetsPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return
            }
        }
        
        self.progressIndicator.startAnimation(nil)
        
        let sorted = images.sorted(by: {
            $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedDescending
        })
        
        var assetsDict = [String: Asset]()
        for imageFileName in sorted {
            var name = (imageFileName as NSString).deletingPathExtension
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
                if let folderPath = folderPath, let path = value.path {
                    let oldPath = (folderPath as NSString).appendingPathComponent(imageName)
                    let newPath = (path as NSString).appendingPathComponent(imageName)
                    do {
                        try fm.copyItem(atPath: oldPath, toPath: newPath)
                    } catch {
                        print(error)
                    }
                }
            }
        }
        
        NSWorkspace.shared().openFile(assetsFolderPath)
        
        self.progressIndicator.stopAnimation(nil)
    }
    
}

