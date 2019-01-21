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
    
    var messages = [LogMessage]()
    func parse(_ path: URL) {
        do {
            let data = try String(contentsOf: path)
            let myStrings = data.components(separatedBy: .newlines)
            
            var temp = [LogMessage]()
            for line in myStrings {
                guard let rangeForCouchbaseLiteKey = line.range(of: "] CouchbaseLite") else {
                    continue
                }
                let indexWithCategory = line.index(after: rangeForCouchbaseLiteKey.upperBound)
                let substringWithCategory = line[indexWithCategory...]
                
                guard let rangeForCategory = substringWithCategory.range(of: ":") else {
                    continue
                }
                let indexForMessage = substringWithCategory.index(after: rangeForCategory.upperBound)
                let indexForCategory = substringWithCategory.index(before: rangeForCategory.upperBound)
                let substringWithMessage = line[indexForMessage...]
                let category = String(substringWithCategory[...indexForCategory])
                
                let domains = category.components(separatedBy: " ")
                guard let dom = Domain(rawValue: domains[0]), let lev = Level(rawValue: domains[1])
                    else {
                        continue
                }
                let startIndex = line.startIndex
                let endIndexForTime = line.index(startIndex, offsetBy: 25)
                let startIndexForTime = line.index(startIndex, offsetBy: 11)
                let timestamp = String(line[startIndexForTime...endIndexForTime])
                
                temp.append(LogMessage(domain: dom,
                                       level: lev,
                                       time: timestamp,
                                       message: String(substringWithMessage)))
            }
            
            messages = temp
            NotificationCenter.default.post(name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                            object: nil)
            
        } catch {
            print(error)
        }
    }
}
