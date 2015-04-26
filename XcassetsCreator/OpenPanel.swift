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
    
    class func open(onFinish: ((String?) -> ())) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let fm = NSFileManager.defaultManager()
                for URL in panel.URLs {
                    if let path = (URL as? NSURL)?.path  {
                        onFinish(path)
                        return
                    }
                }
                onFinish(nil)
            }
        }
    }
    
}
