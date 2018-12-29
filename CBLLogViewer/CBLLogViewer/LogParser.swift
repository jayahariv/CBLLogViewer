//
//  LogParser.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/28/18.
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

class LogParser: NSObject {
    private static let instance = LogParser()
    static var shared: LogParser {
        return instance
    }
    
    var messages = [Message]()
    
    func parse(_ path: URL) {
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
            
            messages = temp
            
            NotificationCenter.default.post(name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                            object: nil)
            
        } catch {
            print(error)
        }
    }
    
}
