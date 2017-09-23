//
//  DatabaseFileSystemReader.swift
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

public class DatabaseFileSystemReader {
    
    let reader: DataStoreReader
    
    let fileTable = "FileTable"
    
    let dataTable = "DataTable"
    
    let folderTable = "FolderTable"
    
    let parentIndex = "ParentIndex"
    
    public init(reader: DataStoreReader) {
        self.reader = reader
    }
    
    public func list(_ parents: [String] = [], deep: Bool = false) throws -> (folders: [String], files: [String]) {
        var files: [String] = [], folders: [String] = []
        if deep {
            for item in try reader.deep(name: parentIndex, page: { parentPage($0) }, filter: { k, r, v in try self.parentFilter(r, parent: v) }, decode: DatabaseParentCodec.init, children: { parentData in parentData.isFile ? [] : [parentData.path] }, startWith: [parents.reducePath()]) {
                if item.isFile { files.append(item.path) } else { folders.append(item.path) }
            }
        } else {
            let parent = parents.reducePath()
            for item in try reader.list(name: parentIndex, page: parentPage(parent), filter: { k, r in try self.parentFilter(r, parent: parent) }, decode: DatabaseParentCodec.init) {
                if item.isFile { files.append(item.name) } else { folders.append(item.name) }
            }
        }
        return (folders, files)
    }
    
    public func existFile(_ parents: [String], name: String) throws -> Bool {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        
        guard let parentData = try reader.get(name: parentIndex, page: self.parentPage(parent), filter: { k, r in try parentUniqueFilter(r, parent: parent, name: name, file: true) }, decode: DatabaseParentCodec.init) else { return false }
        
        guard let dataId = parentData.dataId else { return false }
        
        return try reader.exist(name: dataTable, page: dataPage(dataId), id: dataId)
    }

    public func existFolder(_ parents: [String], name: String) throws -> Bool {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        
        guard let parentData = try reader.get(name: parentIndex, page: self.parentPage(parent), filter: { k, r in try parentUniqueFilter(r, parent: parent, name: name, file: false) }, decode: DatabaseParentCodec.init) else { return false }
        
        guard parentData.dataId == nil else { return false }
        
        return try reader.exist(name: folderTable, page: folderPage(parentData.childId), id: parentData.childId)
    }

    public func readFile(_ parents: [String], name: String) throws -> Json {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        let parentPage = self.parentPage(parent)
        
        guard let parentData = try reader.get(name: parentIndex, page: parentPage, filter: { k, r in try parentUniqueFilter(r, parent: parent, name: name, file: true) }, decode: DatabaseParentCodec.init) else { throw DatabaseFileSystemError.notFoundParentAtPage }
        
        guard let dataId = parentData.dataId else { throw DatabaseFileSystemError.resourceIsNotAFile }
        
        return try reader.get(name: dataTable, page: dataPage(dataId), id: dataId, decode: DatabaseDataCodec.init).json
    }
    
    internal func checkFolder(_ parents: [String]) throws {
        var array = parents
        var aux: [String] = []
        while !array.isEmpty {
            let parentPath = aux.reducePath(), name = array.first!
            guard let _ = try reader.get(name: parentIndex, page: parentPage(parentPath), filter: { k, r in try parentUniqueFilter(r, parent: parentPath, name: name, file: false) }, decode: DatabaseParentCodec.init) else { throw DatabaseFileSystemError.parentFolderNotFound(parentPath) }
            aux.append(array.removeFirst())
        }
    }
    
    func folderPage(_ id: Int) -> Int {
        return id / 32
    }
    
    func filePage(_ id: Int) -> Int {
        return id / 32
    }
    
    func dataPage(_ id: Int) -> Int {
        return id
    }
    
    func parentPage(_ path: String) -> Int {
        return path.utf8.reduce(Int(0), { $0 + Int($1) - 32 }) / 1024
    }
    
    func parentFilter(_ record: DataStoreRecord, parent: String) throws -> Bool {
        return try record.requireString("parent") == parent
    }
    
    func parentFilter(_ record: DataStoreRecord, parent: String, file: Bool) throws -> Bool {
        return try self.parentFilter(record, parent: parent) && (file ? record.getInt("dataid") != nil : record.getInt("dataid") == nil)
    }
    
    func parentFilter(_ record: DataStoreRecord, parent: String, name: String) throws -> Bool {
        return try self.parentFilter(record, parent: parent) && record.requireString("name") == name
    }
    
    func parentUniqueFilter(_ record: DataStoreRecord, parent: String, name: String, file: Bool) throws -> Bool {
        return try self.parentFilter(record, parent: parent, file: file) && record.requireString("name") == name
    }
    
}
