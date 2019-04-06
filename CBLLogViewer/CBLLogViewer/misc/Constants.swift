//
//  Constants.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/28/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Cocoa

struct Constants {
    static let DID_LOG_PARSE_NOTIFICATION = Notification.Name(rawValue: "didLogParse")
    static let DID_LOG_SELECT_NOTIFICATION = Notification.Name(rawValue: "didLogSelect")
    static let DID_LOG_CHANGED_NOTIFICATION = Notification.Name(rawValue: "didLogsChanged")
}
