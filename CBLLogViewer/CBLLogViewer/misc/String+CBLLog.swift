//
//  String+CBLLog.swift
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

extension String {
    func isValidLog(_ isFileLog: Bool) -> Bool {
        guard !isFileLog else {
            // handle later
            return true
        }
        
        let pattern = Constants.CONSOLE_DATE_REGEX + "\\s+[a-z]+\\[+[0-9]+\\:[0-9]+\\]+\\s+CouchbaseLite"
        if self.range(of: pattern,
                      options: .regularExpression,
                      range: nil,
                      locale: nil) != nil {
            return true
        }
        return false
    }
}
