//
//  LogMessage.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/30/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

enum Domain: String {
    case db = "[DB]"
    case sync = "[Sync]"
    case blip = "[BLIP]"
    case ws = "[WS]"
    case query = "[Query]"
}

struct LogMessage {
    let domain: Domain
    let date: Date
    let message: String
    
    var dateDisplayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }
}
