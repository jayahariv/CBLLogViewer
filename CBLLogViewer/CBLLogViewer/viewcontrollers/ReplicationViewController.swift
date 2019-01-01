//
//  ReplicationViewController.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/28/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Cocoa

class ReplicationViewController: NSViewController {
    
    var logs = [LogReplicator]()
    
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
        
        logs = LogParser.shared.logReplicators
        tableView.reloadData()
    }
    
    // MARK: Button Actions
    
    @objc func onLoad(_ notification: Notification) {
        logs = LogParser.shared.logReplicators
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
        return logs.count
    }
}

extension ReplicationViewController: NSTableViewDelegate {
    private enum CellIdentifiers {
        static let TimeCell = "Time_Cell_ID"
        static let CheckpointCell = "CHECKPOINT_Cell_ID"
        static let PullCell = "PULL_Cell_ID"
        static let PushCell = "PUSH_Cell_ID"
        static let DbCell = "DB_Cell_ID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        var text: String = ""
        var color: NSColor = NSColor.clear
        let log = logs[row]
        if tableColumn == tableView.tableColumns[0] {
            text = log.time
            cellIdentifier = CellIdentifiers.TimeCell
        } else if tableColumn == tableView.tableColumns[1] {
            color = NSColor.orange
            cellIdentifier = CellIdentifiers.CheckpointCell
        } else if tableColumn == tableView.tableColumns[2] {
            color = log.status.pull == Status.busy ? .orange : .gray
            cellIdentifier = CellIdentifiers.PullCell
        } else if tableColumn == tableView.tableColumns[3] {
            color = log.status.push == Status.busy ? .orange : .gray
            cellIdentifier = CellIdentifiers.PushCell
        } else if tableColumn == tableView.tableColumns[4] {
            color = log.status.db == Status.busy ? .orange : .gray
            cellIdentifier = CellIdentifiers.DbCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),
                                         owner: nil) as? NSTableCellView {
            
            (cell.viewWithTag(1) as? NSTextField)?.backgroundColor = color
            (cell.viewWithTag(2) as? NSTextField)?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
//        let table = notification.object as! NSTableView
//        let message = logs[table.selectedRow]
//        messageDetailTextField.stringValue = message.message
    }
}

