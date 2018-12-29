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
    
    @IBOutlet private weak var messageDetailTextField: NSTextField!
    @IBOutlet private weak var tableView: NSTableView!

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLoad(_:)),
                                               name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                               object: nil)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        messages = LogParser.shared.messages
        tableView.reloadData()
    }
    
    // MARK: Button Actions
    
    @objc func onLoad(_ notification: Notification) {
        messages = LogParser.shared.messages
    }
}

private extension ReplicationViewController {
    func initUI() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ReplicationViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }
}

extension ReplicationViewController: NSTableViewDelegate {
    private enum CellIdentifiers {
        static let TimeCell = "Time_Cell_ID"
        static let PULLCell = "PULL_Cell_ID"
        static let PUSHCell = "PUSH_Cell_ID"
        static let DBCell = "DB_Cell_ID"
        static let USERCell = "USER_Cell_ID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        var text: String = ""
        var color: NSColor = NSColor.clear
        let message = messages[row]
        if tableColumn == tableView.tableColumns[0] {
            text = message.time
            cellIdentifier = CellIdentifiers.TimeCell
        } else if tableColumn == tableView.tableColumns[1] {
            color = message.domain == .ws ? NSColor.blue : NSColor.clear
            cellIdentifier = CellIdentifiers.PULLCell
        } else if tableColumn == tableView.tableColumns[2] {
            color = message.domain == .blip ? NSColor.green : NSColor.clear
            cellIdentifier = CellIdentifiers.PUSHCell
        } else if tableColumn == tableView.tableColumns[3] {
            color = message.domain == .sync ? NSColor.orange : NSColor.clear
            cellIdentifier = CellIdentifiers.DBCell
        } else if tableColumn == tableView.tableColumns[4] {
            color = message.domain == .db ? NSColor.purple : NSColor.clear
            cellIdentifier = CellIdentifiers.USERCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),
                                         owner: nil) as? NSTableCellView {
            
            cell.textField?.backgroundColor = color
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let table = notification.object as! NSTableView
        let message = messages[table.selectedRow]
        messageDetailTextField.stringValue = message.message
    }
}

