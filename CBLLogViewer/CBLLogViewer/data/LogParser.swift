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
    var logReplicators = [LogReplicator]()
    
    func parse(_ path: URL) {
        do {
            let data = try String(contentsOf: path)
            let myStrings = data.components(separatedBy: .newlines)
            
            var temp = [LogMessage]()
            var tempLogReplicator = [LogReplicator]()
            var status = ReplicatorStatus(push: .idle, pull: .idle, db: .idle)
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
                        fatalError()
                }
                let startIndex = line.startIndex
                let endIndexForTime = line.index(startIndex, offsetBy: 25)
                let startIndexForTime = line.index(startIndex, offsetBy: 11)
                let timestamp = String(line[startIndexForTime...endIndexForTime])
                
                if let logReplicator = getParseReplicator(substringWithMessage,
                                                          timestamp: timestamp,
                                                          status: status,
                                                          level: lev) {
                    status = logReplicator.status
                    tempLogReplicator.append(logReplicator)
                }
                
                let message = LogMessage(domain: dom,
                                         level: lev,
                                         time: timestamp,
                                         message: String(substringWithMessage))
                temp.append(message)
            }
            
            messages = temp
            logReplicators = tempLogReplicator
            
            NotificationCenter.default.post(name: Constants.DID_LOG_PARSE_NOTIFICATION,
                                            object: nil)
            
        } catch {
            print(error)
        }
    }
    
    func getParseReplicator(_ substringWithMessage: Substring,
                            timestamp: String,
                            status: ReplicatorStatus,
                            level: Level) -> LogReplicator? {
        if let indexAfterActivityType = substringWithMessage.firstIndex(of: "}") {
            let indexTillActivityType = substringWithMessage.index(before: indexAfterActivityType)
            let activity = substringWithMessage[..<indexTillActivityType]
            if let activityType = ReplicationType(rawValue: String(activity)) {
                var status = status
                if level == .info && substringWithMessage.range(of: "pushStatus=") != nil {
                    let allStatus = substringWithMessage.components(separatedBy: " ")
                    if
                        let push = Status(rawValue: String(allStatus[1].suffix(5))),
                        let pull = Status(rawValue: String(allStatus[2].suffix(5))),
                        let db = Status(rawValue: String(allStatus[3].suffix(5))) {
                        status = ReplicatorStatus(push: push, pull: pull, db: db)
                    }
                }
                return LogReplicator(time: timestamp,
                                     type: activityType,
                                     status: status,
                                     revision: nil,
                                     revisionStatus: .none)
            }
        }
        return nil
    }
}
