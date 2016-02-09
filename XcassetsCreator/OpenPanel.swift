//
//  OpenPanel.swift
//  XcassetsCreator
//
//  Created by Andrey Isaev on 26.04.15.
//  Copyright (c) 2015 Andrey Isaev. All rights reserved.
//

import Foundation
import Cocoa

class OpenPanel: NSObject {
    
    class func open(onFinish: (([String]?) -> ())) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = true
        panel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                var selected = [String]()
                let fm = NSFileManager.defaultManager()
                for URL in panel.URLs {
                    if let path = URL.path  {
                        var isDirectory: ObjCBool = false
                        if fm.fileExistsAtPath(path, isDirectory: &isDirectory) && isDirectory {
                            selected.append(path)
                            selected += self.recursiveGetDirectoriesFromDirectory(path)
                        }
                    }
                }
                onFinish(selected)
            }
        }
    }
    
    class func recursiveGetDirectoriesFromDirectory(directoryPath: String) -> [String] {
        var results = [String]()
        let fm = NSFileManager.defaultManager()
        do {
            let fileNames = try fm.contentsOfDirectoryAtPath(directoryPath)
            for fileName in fileNames {
                let path = (directoryPath as NSString).stringByAppendingPathComponent(fileName)
                
                var isDirectory: ObjCBool = false
                if fm.fileExistsAtPath(path, isDirectory: &isDirectory) {
                    if isDirectory {
                        results.append(path)
                        results += recursiveGetDirectoriesFromDirectory(path)
                    }
                }
            }
        } catch {
            print(error)
        }
        return results
    }
    
}
