//
//  LogParser.swift
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

enum LogParserError: Error {
    case unsupported
    case noData
}


class LogParser: NSObject {
    // Properties
    public var messages = [LogMessage]()
    public var errors = [String]()
    
    private var headerInfo: String!
    private let _url: URL!
    
    var isSupported: Bool {
        return _url.pathExtension == "cbllog" || _url.pathExtension == "txt"
    }
    
    var isFileLog: Bool {
        return _url.pathExtension == "cbllog"
    }
    
    // MARK: Constructors
    
    private override init() { _url = nil }
    
    init(_ url: URL) {
        _url = url
    }
    
    // MARK: Parser
    
    /**
     Parse will parse the fileURL contents.
     When parsing is done, will post the notification named `Constants.DID_LOG_PARSE_NOTIFICATION`.
     
     - todo:
        1. header information
        2. push/pull/repl progress
        3. handle when console log contents, now only handles the cbllog extension files.
     */
    func parse() throws {
        if !isSupported {
            throw LogParserError.unsupported
        }
        print("parse file at: \(_url.absoluteString)")
        let lines = try getAllLines()
        
        let logs: [LogMessage]!
        if isFileLog {
            logs = try parseFileLog(lines)
        } else {
            logs = try parseConsoleLog(lines)
        }
        
        print("done parsing!")
        if logs.count == 0 {
            throw LogParserError.noData
        }
        
        messages = logs
        NotificationCenter.default.post(name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                        object: self)
    }
    
    func parseFileLog(_ lines: IndexingIterator<[String]>) throws -> [LogMessage] {
        var lines = lines
        print("parse file log")
        
        let dateFormatter = Utility.dateFormatter(true)
        if let time = extractTimestamp() {
            let dateOfLog = Date(timeIntervalSince1970: time/1000)
            dateFormatter.defaultDate = dateOfLog
        }
        
        var temp = [LogMessage]()
        while let line = lines.next() {
            guard line.isValidLog(true) else {
                continue
            }
            
            guard let rangeOfTimestamp = line.range(of: "| ") else {
                continue
            }
            let dateString = String(line[..<rangeOfTimestamp.lowerBound])
            guard let date = dateFormatter.date(from: dateString) else {
                continue
            }
            guard let rangeOfDomain = line.range(of: ": ") else {
                continue
            }
            let domainString = String(line[rangeOfTimestamp.upperBound..<rangeOfDomain.lowerBound])
            guard let domain = Domain(rawValue: domainString) else {
                continue
            }
            
            let message = String(line[rangeOfDomain.upperBound...])
            var isPush = false
            var isPull = false
            if message.range(of: "{Push#") != nil {
                isPush = true
                let infos = message.split(separator: " ")
                if infos.count == 12 && infos[1] == "progress" {
                    print(message)
                }
            }
            if message.range(of: "{Pull#") != nil {
                isPull = true
            }
            let push = Push(isPush: isPush, progress: 0.0)
            let pull = Pull(isPull: isPull, progress: 0.0)
            let repl = Repl(isRepl: message.range(of: "{Repl#") != nil, progress: 0.0)
            temp.append(LogMessage(domain: domain,
                                   date: date,
                                   message: message,
                                   push: push,
                                   pull: pull,
                                   repl: repl))
        }
        
        return temp
    }
    
    func parseConsoleLog(_ lines: IndexingIterator<[String]>) throws -> [LogMessage] {
        var lines = lines
        var temp = [LogMessage]()
        let dateFormatter = Utility.dateFormatter(false)
        while let line = lines.next() {
            guard line.isValidLog(false) else {
                continue
            }
            
            guard let rangeOfTimestamp = line.range(of: "| ") else {
                continue
            }
            let dateString = String(line[..<rangeOfTimestamp.lowerBound])
            guard let date = dateFormatter.date(from: dateString) else {
                continue
            }
            guard let rangeOfDomain = line.range(of: ": ") else {
                continue
            }
            let domainString = String(line[rangeOfTimestamp.upperBound..<rangeOfDomain.lowerBound])
            guard let domain = Domain(rawValue: domainString) else {
                continue
            }
            
            let message = String(line[rangeOfDomain.upperBound...])
            var isPush = false
            var isPull = false
            if message.range(of: "{Push#") != nil {
                isPush = true
                let infos = message.split(separator: " ")
                if infos.count == 12 && infos[1] == "progress" {
                    print(message)
                }
            }
            if message.range(of: "{Pull#") != nil {
                isPull = true
            }
            let push = Push(isPush: isPush, progress: 0.0)
            let pull = Pull(isPull: isPull, progress: 0.0)
            let repl = Repl(isRepl: message.range(of: "{Repl#") != nil, progress: 0.0)
            temp.append(LogMessage(domain: domain,
                                   date: date,
                                   message: message,
                                   push: push,
                                   pull: pull,
                                   repl: repl))
        }
        
        return temp
    }
}

// MARK: Helper methods
private extension LogParser {
    /**
     gives back all log lines to process,
     
     - returns: valid lines to process
     - todo:
     - needs to trims the begining and end of lines for noises
     */
    func getAllLines() throws -> IndexingIterator<[String]> {
        let data: String!
        do {
            data = try String(contentsOf: _url, encoding: .ascii)
        } catch {
            throw error
        }
        return data.components(separatedBy: .newlines).makeIterator()
    }
    
    /**
     extracts the timestamp from the file if possible. For file logs, we will extract it from the
     filename.
     
     - returns: returns timeInterval, if not possible nil.
     */
    func extractTimestamp() -> TimeInterval? {
        if let ts = _url.deletingPathExtension().lastPathComponent.split(separator: "_").last,
            let time = TimeInterval(ts) {
            return time
        }
        
        return nil
    }
}
