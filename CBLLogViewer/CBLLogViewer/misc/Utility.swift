//
//  Utility.swift
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

final class Utility: NSObject {
    static func copyToClipboard(_ message: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(message,
                             forType: NSPasteboard.PasteboardType.string)
    }
    
    static func dateFormatter(_ isFileLog: Bool) -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = isFileLog ? Constants.FILE_DATE_FORMAT : Constants.CONSOLE_DATE_FORMAT
        return df
    }
}
