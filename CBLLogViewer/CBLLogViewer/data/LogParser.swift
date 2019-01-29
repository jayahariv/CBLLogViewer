//
//  LogParser.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/28/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Cocoa

class LogParser: NSObject {
    private static let instance = LogParser()
    static var shared: LogParser {
        return instance
    }
    
    var headerInfo: String!
    
    var messages = [LogMessage]()
    func parse(_ path: URL) {
        do {
            let data = try String(contentsOf: path, encoding: .ascii)
            var allLines = data.components(separatedBy: .newlines)
            headerInfo = allLines.removeFirst()
            
            var temp = [LogMessage]()
            guard
                let timestampFromFilename = path.deletingPathExtension()
                    .lastPathComponent
                    .split(separator: "_")
                    .last,
                let time = TimeInterval(timestampFromFilename) else {
                fatalError("timestamp for filename")
            }
            
            let dateOfLog = Date(timeIntervalSince1970: time/1000)
            print("Date: \(dateOfLog)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss.SSSSSS"
            dateFormatter.defaultDate = dateOfLog
            
            for line in allLines {
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
                temp.append(LogMessage(domain: domain,
                                       date: date,
                                       message: message))
            }
            
            messages = temp
            NotificationCenter.default.post(name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                            object: nil)
            
        } catch {
            print(error)
        }
    }
}
