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

struct LogParserConstants {
    static let fileDateFormat  = "HH:mm:ss.SSSSSS"
    static let consoleDateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
}

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
        return _url.pathExtension == "cbllog"
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
        print("going to parse file at: \(_url.absoluteString)")
        
        var allLines = try getAllLines()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = isFileLog
            ? LogParserConstants.fileDateFormat
            : LogParserConstants.consoleDateFormat
        if let time = extractTimestamp() {
            let dateOfLog = Date(timeIntervalSince1970: time/1000)
            dateFormatter.defaultDate = dateOfLog
        }
        
        var pushProgress: Double?
        var pullProgress: Double?
        var replProgress: Double?
        var temp = [LogMessage]()
        
        print("starting to parse the logs")
        while let line = allLines.next() {
            guard line.isValidLog() else {
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
            if let range = message.range(of: "{Push#") {
                isPush = true
                let infos = message.split(separator: " ")
                if infos.count == 12 && infos[1] == "progress" {
                    print(message)
                }
            }
            if message.range(of: "{Pull#") != nil {
                isPull = true
            }
            let push = Push(isPush: isPush, progress: pushProgress)
            let pull = Pull(isPull: isPull, progress: pullProgress)
            let repl = Repl(isRepl: message.range(of: "{Repl#") != nil, progress: replProgress)
            temp.append(LogMessage(domain: domain,
                                   date: date,
                                   message: message,
                                   push: push,
                                   pull: pull,
                                   repl: repl))
        }
        print("finish parsing the logs")
        if temp.count == 0 {
            throw LogParserError.noData
        }
        
        messages = temp
        NotificationCenter.default.post(name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                        object: self)
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
