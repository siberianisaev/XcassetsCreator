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
    
    class func open(_ onFinish: @escaping (([String]?) -> ())) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = true
        panel.begin { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                var selected = [String]()
                let fm = FileManager.default
                for URL in panel.urls {
                    let path = URL.path
                    var isDirectory: ObjCBool = false
                    if fm.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue {
                        selected.append(path)
                        selected += self.recursiveGetDirectoriesFromDirectory(path)
                    }
                }
                onFinish(selected)
            }
        }
    }
    
    class func recursiveGetDirectoriesFromDirectory(_ directoryPath: String) -> [String] {
        var results = [String]()
        let fm = FileManager.default
        do {
            let fileNames = try fm.contentsOfDirectory(atPath: directoryPath)
            for fileName in fileNames {
                let path = (directoryPath as NSString).appendingPathComponent(fileName)
                
                var isDirectory: ObjCBool = false
                if fm.fileExists(atPath: path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
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
