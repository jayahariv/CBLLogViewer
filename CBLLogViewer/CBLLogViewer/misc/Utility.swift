//
//  Utility.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 4/6/19.
//  Copyright © 2019 Jayahari Vavachan. All rights reserved.
//

import Cocoa

class Utility: NSObject {
    private static let instance = Utility()
    static var shared: Utility {
        return instance
    }
    
    func copyToClipboard(_ message: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(message,
                             forType: NSPasteboard.PasteboardType.string)
    }
}
