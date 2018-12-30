//
//  Replication.swift
//  CBLLogViewer
//
//  Created by Jayahari Vavachan on 12/30/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

struct LogReplicator {
    let type: ReplicationType
    let status: Status
    let progressPercentage: Float
    let revision: String // next revision
    let revisionStatus: RevisionStatus
    let checkpoint: CheckPoint
}

struct CheckPoint {
    let id: String
    let local: String
    let remote: String
}

// MARK: ENUMs

enum Status {
    case busy, idle
}

enum RevisionStatus {
    case incoming, inserting, completed, notify
}

enum ReplicationType {
    case pull, push
}
