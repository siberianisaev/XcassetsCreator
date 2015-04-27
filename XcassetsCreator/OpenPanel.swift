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
                    if let path = (URL as? NSURL)?.path  {
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
        
        var error: NSError? = nil
        let fm = NSFileManager.defaultManager()
        if let fileNames = (fm.contentsOfDirectoryAtPath(directoryPath, error: &error) as? [String]) {
            for fileName in fileNames {
                let path = directoryPath.stringByAppendingPathComponent(fileName)
                
                var isDirectory: ObjCBool = false
                if fm.fileExistsAtPath(path, isDirectory: &isDirectory) {
                    if isDirectory {
                        results.append(path)
                        results += recursiveGetDirectoriesFromDirectory(path)
                    }
                }
            }
        }
        
        return results
    }
    
}
