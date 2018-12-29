//
//  HomeViewController.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/27/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Cocoa

enum Domain: String {
    case db = "DB"
    case sync = "Sync"
    case blip = "BLIP"
    case ws = "WS"
    case query = "Query"
}

enum Level: String {
    case verbose = "Verbose:"
    case info = "Info:"
    case error = "ERROR:"
}

struct Message {
    let domain: Domain
    let level: Level
    let time: String
    let message: String
}

class HomeViewController: NSViewController {
    
    // MARK: Properties
    
    private var messages = [Message]()
    private var totalMessages = [Message]()
    private var fileURL: URL?
    
    /// IB Properties
    @IBOutlet private weak var parseButton: NSButton!
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
        dialog.allowedFileTypes = ["txt"];
        
        if (dialog.runModal() == .OK) {
            fileURL = dialog.url
            
            configureAnalyse(true)
        } else {
            // User clicked on "Cancel"
            return
        }
    }

    
    @IBAction func parse(sender: AnyObject) {
        parse()
    }
    
    
    @IBAction func filter(sender: AnyObject) {
        filter()
    }
}


private extension HomeViewController {
    
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
    
    func configureAnalyse(_ enable: Bool) {
        parseButton.isEnabled = enable
    }
    
    func initUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        configureAnalyse(false)
        configureFilterOptions(false)
    }
    
    func parse() {
        guard let path = fileURL else {
            fatalError()
        }
        
        do {
            let data = try String(contentsOf: path)
            let myStrings = data.components(separatedBy: .newlines)
            
            var temp = [Message]()
            for line in myStrings {
                guard let rangeForCouchbaseLiteKey = line.range(of: "CouchbaseLite") else {
                    continue
                }
                let indexWithCategory = line.index(after: rangeForCouchbaseLiteKey.upperBound)
                let substringWithCategory = line[indexWithCategory...]
                
                guard let rangeForCategory = substringWithCategory.range(of: ":") else {
                    fatalError()
                }
                let indexForMessage = substringWithCategory.index(after: rangeForCategory.upperBound)
                let indexForCategory = substringWithCategory.index(before: rangeForCategory.upperBound)
                let substringWithMessage = line[indexForMessage...]
                let category = String(substringWithCategory[...indexForCategory])
                
                let domains = category.components(separatedBy: " ")
                guard let dom = Domain(rawValue: domains[0]), let lev = Level(rawValue: domains[1])
                    else {
                        fatalError()
                }
                let startIndex = line.startIndex
                let endIndexForTime = line.index(startIndex, offsetBy: 25)
                let startIndexForTime = line.index(startIndex, offsetBy: 11)
                let timestamp = line[startIndexForTime...endIndexForTime]
                
                let message = Message(domain: dom,
                                      level: lev,
                                      time: String(timestamp),
                                      message: String(substringWithMessage))
                
                temp.append(message)
            }
            totalMessages = temp
            messages = temp
            tableView.reloadData()
            configureFilterOptions(true)
        } catch {
            print(error)
        }
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
}

extension HomeViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }
}

extension HomeViewController: NSTableViewDelegate {
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
                text = "e"
            case .info:
                text = "i"
            case .verbose:
                text = "v"
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
