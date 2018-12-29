//
//  ReplicationViewController.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/28/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Cocoa

class ReplicationViewController: NSViewController {
    
    var messages = [Message]()

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLoad(_:)),
                                               name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                               object: nil)
    }
    
    // MARK: Button Actions
    
    @objc func onLoad(_ notification: Notification) {
        messages = LogParser.shared.messages
    }
}
