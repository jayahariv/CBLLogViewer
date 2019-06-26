//
//  LogMessage.swift
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

import Foundation

enum Domain: String {
    case db = "[DB]"
    case sync = "[Sync]"
    case blip = "[BLIP]"
    case ws = "[WS]"
    case query = "[Query]"
    case unknown
}

extension Domain {
    static func getDomainFromConsoleLog(_ domainString: String) -> Domain {
        switch domainString {
            case "Database": return .db
            case "Replicator": return .sync
            case "Network": return .blip
            case "Websocket": return .ws
            case "Query": return .query
            default: return .unknown
        }
    }
}

enum Level: String {
    case debug = "Debug:"
    case verbose = "Verbose:"
    case info = "Info:"
    case warning = "WARNING:"
    case error = "ERROR:"
    case unknown
}

struct LogMessage {
    let domain: Domain
    let date: Date
    let message: String
    
    let push: Push
    let pull: Pull
    let repl: Repl
    
    var dateDisplayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
}

struct Push {
    let isPush: Bool
    let progress: Double?
}

struct Pull {
    let isPull: Bool
    let progress: Double?
}

struct Repl {
    let isRepl: Bool
    let progress: Double?
}
