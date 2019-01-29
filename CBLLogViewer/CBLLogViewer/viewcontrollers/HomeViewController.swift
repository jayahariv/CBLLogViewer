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
    
    private var fileURL: URL?
    /// IB properties
    @IBOutlet private weak var analyzeButton: NSButton!
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
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
            fileURL = dialog.url
            
            configureAnalyse(true)
        }
    }
    
    @IBAction func analyze(sender: AnyObject) {
        guard let path = fileURL else {
            fatalError()
        }
        
        LogParser.shared.parse(path)
    }
}

// MARK: Helper Methods

private extension HomeViewController {
    func initUI() {
        configureAnalyse(false)
    }
    
    func configureAnalyse(_ enable: Bool) {
        analyzeButton.isEnabled = enable
    }
}
