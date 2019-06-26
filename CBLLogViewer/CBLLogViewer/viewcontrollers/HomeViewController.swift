//
//  HomeViewController.swift
//  CBLLogViewer
//
//  Copyright (c) 2019 Couchbase, Inc All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa

class HomeViewController: NSViewController {
    
    // MARK: Properties
    private var selectedLog: LogMessage?
    private var logs = [LogMessage]()
    private var parser: LogParser?
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLoad(_:)),
                                               name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                               object: nil)
        
        setDetailsUI()
    }
    
    // MARK: Helper methods
    
    func setDetailsUI() {
        detailView.wantsLayer = true
        detailView.layer?.borderWidth = 0.5
    }
    
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
        dialog.title = "Choose the log file"
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseDirectories = true;
        dialog.canCreateDirectories = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes = ["cbllog", "txt"];
        
        if (dialog.runModal() == .OK) {
            guard let path = dialog.url else {
                fatalError()
            }
            
            parser = LogParser(path)
            do {
                try parser?.parse()
            } catch {
                print("Error happened while parsing: \(error)")
            }
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
        Utility.copyToClipboard(message)
    }
    
    @IBAction func onCopyMessage(_ sender: Any) {
        guard let log = selectedLog else {
            return
        }
        Utility.copyToClipboard("\(log.dateDisplayString): \(log.message)")
    }
    
    @IBAction func onToggleDetailSection(_ sender: NSButton) {
        widthContraint.constant = sender.state == .on ? 300.0 : 0.0
    }
    
    @objc func onLoad(_ notification: Notification) {
        if let parser = parser {
            print("TODO: show the errors in details pane: \(parser.errors)")
        }
    }
}
