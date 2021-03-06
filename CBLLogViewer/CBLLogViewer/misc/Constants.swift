//
//  Constants.swift
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

struct Constants {
    static let DID_LOG_PARSE_NOTIFICATION = Notification.Name(rawValue: "didLogParse")
    static let DID_LOG_SELECT_NOTIFICATION = Notification.Name(rawValue: "didLogSelect")
    static let DID_LOG_CHANGED_NOTIFICATION = Notification.Name(rawValue: "didLogsChanged")
    
    static let FILE_DATE_FORMAT  = "HH:mm:ss.SSSSSS"
    static let CONSOLE_DATE_FORMAT = "yyyy-MM-dd HH:mm:ss.SSSZ"
    
    static let CONSOLE_DATE_REGEX = "([\\d]{4})+((-[\\d]{2}){2})+\\s+(([\\d]{2}:){2})+([\\d]{2})+\\.+[\\d]+(\\-|\\+)+[0-9]+"
}
