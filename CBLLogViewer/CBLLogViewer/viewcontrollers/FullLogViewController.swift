//
//  FullLogViewController.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/27/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Cocoa

class FullLogViewController: NSViewController {
    
    // MARK: Properties
    
    private var messages = [LogMessage]()
    private var totalMessages = [LogMessage]()
    
    /// IB Properties
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var wsButton: NSButton!
    @IBOutlet private weak var blipButton: NSButton!
    @IBOutlet private weak var syncButton: NSButton!
    @IBOutlet private weak var dbButton: NSButton!
    @IBOutlet private weak var queryButton: NSButton!
    @IBOutlet private weak var messageDetailTextField: NSTextField!
    
    @IBOutlet private weak var infoFilterButton: NSButton!
    @IBOutlet private weak var errorFilterButton: NSButton!
    @IBOutlet private weak var verboseFilterButton: NSButton!
    
    @IBOutlet private weak var searchTextField: NSTextField!
    
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
        
        loadData()
    }
    
    // MARK: Button Actions
    
    @IBAction func filter(sender: AnyObject) {
        filter()
    }
    
    @IBAction func search(sender: AnyObject) {
        let keyword = searchTextField.stringValue
        if !keyword.isEmpty {
            messages = messages.filter({ $0.message.lowercased().range(of: keyword.lowercased()) != nil })
            tableView.reloadData()
        }
    }
    
    @objc func onLoad(_ notification: Notification) {
        loadData()
    }
    
    @IBAction func onCopyMessageDetail(sender: AnyObject) {
        copyToClipboard(messageDetailTextField.stringValue)
    }
    
    @IBAction func copyAll(sender: AnyObject) {
        let message = messages.map({ $0.message }).joined(separator: "\n")
        copyToClipboard(message)
    }
}


private extension FullLogViewController {
    
    func configureFilterOptions(_ enable: Bool) {
        wsButton.isEnabled = enable
        blipButton.isEnabled = enable
        syncButton.isEnabled = enable
        dbButton.isEnabled = enable
        queryButton.isEnabled = enable
        infoFilterButton.isEnabled = enable
        errorFilterButton.isEnabled = enable
        verboseFilterButton.isEnabled = enable
    }
    
    func initUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        configureFilterOptions(false)
    }
    
    func filter() {
        messages = totalMessages.filter({
            ($0.domain == Domain.ws && wsButton.state == .on) ||
                ($0.domain == Domain.blip && blipButton.state == .on) ||
                ($0.domain == Domain.sync && syncButton.state == .on) ||
                ($0.domain == Domain.db && dbButton.state == .on) ||
                ($0.domain == Domain.query && queryButton.state == .on)
        }).filter({
            ($0.level == Level.info && infoFilterButton.state == .on) ||
                ($0.level == Level.error && errorFilterButton.state == .on) ||
                ($0.level == Level.verbose && verboseFilterButton.state == .on)
        })
        tableView.reloadData()
    }
    
    func loadData() {
        totalMessages = LogParser.shared.messages
        messages = LogParser.shared.messages
        configureFilterOptions(messages.count > 0)
        tableView.reloadData()
    }
    
    func copyToClipboard(_ message: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(message,
                             forType: NSPasteboard.PasteboardType.string)
    }
}

extension FullLogViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }
}

extension FullLogViewController: NSTableViewDelegate {
    private enum CellIdentifiers {
        static let TimeCell = "Time_Cell_ID"
        static let WSCell = "WS_Cell_ID"
        static let BLIPCell = "BLIP_Cell_ID"
        static let SYNCCell = "SYNC_Cell_ID"
        static let DBCell = "DB_Cell_ID"
        static let QURYCell = "QURY_Cell_ID"
        static let LevelCell = "Level_Cell_ID"
        static let MessageCell = "Message_Cell_ID"
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
            cellIdentifier = CellIdentifiers.WSCell
        } else if tableColumn == tableView.tableColumns[2] {
            color = message.domain == .blip ? NSColor.green : NSColor.clear
            cellIdentifier = CellIdentifiers.BLIPCell
        } else if tableColumn == tableView.tableColumns[3] {
            color = message.domain == .sync ? NSColor.orange : NSColor.clear
            cellIdentifier = CellIdentifiers.SYNCCell
        } else if tableColumn == tableView.tableColumns[4] {
            color = message.domain == .db ? NSColor.purple : NSColor.clear
            cellIdentifier = CellIdentifiers.DBCell
        } else if tableColumn == tableView.tableColumns[5] {
            color = message.domain == .query ? NSColor.yellow : NSColor.clear
            cellIdentifier = CellIdentifiers.QURYCell
        } else if tableColumn == tableView.tableColumns[6] {
            switch message.level {
            case .error:
                text = "error"
            case .info:
                text = "info"
            case .verbose:
                text = "verbose"
            case .warning:
                text = "warning"
            }
            cellIdentifier = CellIdentifiers.LevelCell
        } else if tableColumn == tableView.tableColumns[7] {
            text = message.message
            cellIdentifier = CellIdentifiers.MessageCell
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
