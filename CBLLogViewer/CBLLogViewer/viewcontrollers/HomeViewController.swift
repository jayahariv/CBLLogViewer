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
    private var selectedLog: LogMessage?
    private var logs = [LogMessage]()
    
    /// IB properties
    @IBOutlet private weak var timestampLabel: NSTextField!
    @IBOutlet private weak var messageDetailLabel: NSTextField!
    @IBOutlet private weak var detailView: NSView!
    @IBOutlet private weak var widthContraint: NSLayoutConstraint!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLogSelect(_:)),
                                               name: Constants.DID_LOG_SELECT_NOTIFICATION,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLogChanged(_:)),
                                               name: Constants.DID_LOG_CHANGED_NOTIFICATION,
                                               object: nil)
    }
    
    // MARK: Helper methods
    
    func updateDetailSection() {
        guard let log = selectedLog else {
            return
        }
        messageDetailLabel.stringValue = "\(log.message)"
        timestampLabel.stringValue = "\(log.dateDisplayString)"
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
            guard let path = dialog.url else {
                fatalError()
            }
            
            LogParser.shared.parse(path)
        }
    }
    
    @objc func onLogSelect(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo as? [String: Any],
            let log = userInfo["log"] as? LogMessage
        else {
            fatalError()
        }
        selectedLog = log;
        updateDetailSection()
    }
    
    @objc func onLogChanged(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo as? [String: Any],
            let logMessages = userInfo["logs"] as? [LogMessage]
            else {
                fatalError()
        }
        logs = logMessages;
    }
    
    @IBAction func onCopyAll(_ sender: Any) {
        let message = logs.map({ "\($0.dateDisplayString): \($0.message)" }).joined(separator: "\n")
        Utility.shared.copyToClipboard(message)
    }
    
    @IBAction func onCopyMessage(_ sender: Any) {
        guard let log = selectedLog else {
            return
        }
        Utility.shared.copyToClipboard("\(log.dateDisplayString): \(log.message)")
    }
    
    @IBAction func onToggleDetailSection(_ sender: NSButton) {
        widthContraint.constant = sender.state == .on ? 300.0 : 0.0
    }
}
