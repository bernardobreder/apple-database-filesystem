//
//  DatabaseFileSystemCodec.swift
//  DatabaseFileSystem
//
//  Created by Bernardo Breder on 17/01/17.
//
//

import Foundation
#if SWIFT_PACKAGE
import DataStore
import FileSystem
import Json
#endif

public class DatabaseFileCodec {
    
    public let id: Int
    
    public let name: String
    
    public let dataId: Int
    
    public init(id: Int, name: String, dataId: Int) {
        self.id = id
        self.name = name
        self.dataId = dataId
    }
    
    public func encode() -> DataStoreRecord {
        return DataStoreRecord(json: Json(["id": id, "name": name, "dataid": dataId]))
    }
    
}

public class DatabaseDataCodec {
    
    public let id: Int
    
    public let json: Json
    
    public convenience init(_ record: DataStoreRecord) throws {
        let id = try record.requireId()
        let jsonString = try record.requireString("data")
        let jsonData = try jsonString.data(using: .utf8).orThrow(DatabaseDataCodecError.decode(id, jsonString))
        let json = try Json(data: jsonData)
        self.init(id: id, json: json)
    }
    
    public init(id: Int, json: Json) {
        self.id = id
        self.json = json
    }
    
    public func encode() throws -> DataStoreRecord {
        return DataStoreRecord(json: Json(["id": id, "data": try json.jsonToString()]))
    }
    
}

public class DatabaseFolderCodec {
    
    public let id: Int
    
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    public func encode() -> DataStoreRecord {
        return DataStoreRecord(json: Json(["id": id, "name": name]))
    }
    
}

internal class DatabaseParentCodec {
    
    public let id: Int
    
    public let parent: String
    
    public let name: String
    
    public let childId: Int
    
    public let dataId: Int?
    
    public convenience init(_ record: DataStoreRecord) throws {
        let id = try record.requireId()
        let parent = try record.requireString("parent")
        let name = try record.requireString("name")
        let childid = try record.requireInt("childid")
        let dataId = record.getInt("dataid")
        self.init(id: id, parent: parent, name: name, childId: childid, dataId: dataId)
    }
    
    public init(id: Int, parent: String, name: String, childId: Int, dataId: Int? = nil) {
        self.id = id
        self.parent = parent
        self.name = name
        self.childId = childId
        self.dataId = dataId
    }
    
    public var isFile: Bool {
        return dataId != nil
    }
    
    public var path: String {
        return parent == "/" ? "/" + name :  parent + "/" + name
    }
    
    public func encode() -> DataStoreRecord {
        return DataStoreRecord(json: Json(["id": id, "parent": parent, "name": name, "childid": childId, "dataid": dataId ?? NSNull() as Any]))
    }
    
}

public enum DatabaseDataCodecError: Error {
    case decode(Int, String)
}
