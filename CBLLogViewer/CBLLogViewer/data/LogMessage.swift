//
//  LogMessage.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/30/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

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

struct LogMessage {
    let domain: Domain
    let level: Level
    let time: String
    let message: String
}
