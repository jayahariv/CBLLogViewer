//
//  Replication.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/30/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

struct LogReplicator {
    let time: String
    let type: ReplicationType
    let status: ReplicatorStatus
    let revision: String?
    let revisionStatus: RevisionStatus
}

struct CheckPoint {
    let id: String
    let local: String
    let remote: String
}

struct ReplicatorStatus {
    let push: Status
    let pull: Status
    let db: Status
}

// MARK: ENUMs

enum Status: String {
    case busy = "busy,"
    case idle = "idle,"
}

enum RevisionStatus {
    case incoming, inserting, completed, notify, none
}

enum ReplicationType: String {
    case pull = "{Pull#"
    case push = "{Push#"
    case dbworker = "{DBWorker#"
    case replicator = "{Repl#"
}
