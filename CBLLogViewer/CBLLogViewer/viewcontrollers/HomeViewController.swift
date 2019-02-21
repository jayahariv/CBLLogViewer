//
//  HomeViewController.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/28/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController {
    
    // MARK: Properties
    /// IB properties
    @IBOutlet private weak var analyzeButton: NSButton!
    
    
    // MARK: Button Actions
    
    @IBAction func browseFile(sender: AnyObject) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a .txt file"
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseDirectories = true;
        dialog.canCreateDirectories = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes = ["cbllog"];
        
        if (dialog.runModal() == .OK) {
            guard let path = dialog.url else {
                fatalError()
            }
            
            LogParser.shared.parse(path)
        }
    }
}
