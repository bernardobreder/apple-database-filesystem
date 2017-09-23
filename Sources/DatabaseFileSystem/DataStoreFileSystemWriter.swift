//
//  DataStoreFileSystemWriter.swift
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

public class DatabaseFileSystemWriter: DatabaseFileSystemReader {
    
    let writer: DataStoreWriter
    
    public init(writer: DataStoreWriter) {
        self.writer = writer
        super.init(reader: writer)
    }
    
    public func createFile(_ parents: [String], name: String, json: Json = Json([:])) throws {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        
        if let parentData = try reader.get(name: parentIndex, page: self.parentPage(parent), filter: { k, r in try parentFilter(r, parent: parent, name: name) }, decode: DatabaseParentCodec.init) {
            guard let dataId = parentData.dataId else { throw DatabaseFileSystemError.alreadyFolderWithThisName(parents, name) }
            let dataData = DatabaseDataCodec.init(id: dataId, json: json)
            
            writer.update(name: dataTable, page: dataPage(dataId), id: dataId, record: try dataData.encode())
        } else {
            let dataData = try DatabaseDataCodec(id: writer.sequence(name: dataTable), json: Json([:]))
            let fileData = try DatabaseFileCodec(id: writer.sequence(name: fileTable), name: name, dataId: dataData.id)
            let parentData = DatabaseParentCodec(id: try writer.sequence(name: parentIndex), parent: parents.reducePath(), name: name, childId: fileData.id, dataId: dataData.id)
            
            writer.insert(name: fileTable, page: filePage(fileData.id), id: fileData.id, record: fileData.encode())
            writer.insert(name: dataTable, page: dataPage(dataData.id), id: dataData.id, record: try dataData.encode())
            writer.insert(name: parentIndex, page: parentPage(parentData.parent), id: parentData.id, record: parentData.encode())
        }
    }
    
    public func deleteFile(_ parents: [String], name: String) throws {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        let parentPage = self.parentPage(parent)
        
        guard let parentData: DatabaseParentCodec = try writer.get(name: parentIndex, page: parentPage, filter: { k, r in try parentUniqueFilter(r, parent: parent, name: name, file: true) }, decode: DatabaseParentCodec.init) else { throw DatabaseFileSystemError.notFoundParentAtPage }
        
        writer.delete(name: fileTable, page: filePage(parentData.childId), id: parentData.childId)
        writer.delete(name: dataTable, page: dataPage(parentData.dataId!), id: parentData.dataId!)
        writer.delete(name: parentIndex, page: parentPage, id: parentData.id)
    }
    
    public func renameFile(_ parents: [String], from: String, to: String) throws {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        let parentPage = self.parentPage(parent)
        
        guard let parentData: DatabaseParentCodec = try writer.get(name: parentIndex, page: parentPage, filter: { k, r in try parentUniqueFilter(r, parent: parent, name: from, file: true) }, decode: DatabaseParentCodec.init) else { throw DatabaseFileSystemError.notFoundParentAtPage }
        
        let fileData = DatabaseFileCodec(id: parentData.childId, name: to, dataId: parentData.dataId!)
        let newParentData = DatabaseParentCodec(id: parentData.id, parent: parentData.parent, name: to, childId: parentData.childId, dataId: parentData.dataId)
        
        writer.update(name: fileTable, page: filePage(parentData.childId), id: parentData.childId, record: fileData.encode())
        writer.update(name: parentIndex, page: parentPage, id: parentData.id, record: newParentData.encode())
    }
    
    public func createFolder(_ parents: [String], name: String) throws {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        
        if let parentData = try reader.get(name: parentIndex, page: self.parentPage(parent), filter: { k, r in try parentFilter(r, parent: parent, name: name) }, decode: DatabaseParentCodec.init) {
            guard parentData.dataId == nil else { throw DatabaseFileSystemError.alreadyFileWithThisName(parents, name) }
        } else {
            let folderData = try DatabaseFolderCodec(id: writer.sequence(name: folderTable), name: name)
            let parentData = try DatabaseParentCodec(id: writer.sequence(name: parentIndex), parent: parents.reducePath(), name: name, childId: folderData.id)
            
            writer.insert(name: folderTable, page: folderPage(folderData.id), id: folderData.id, record: folderData.encode())
            writer.insert(name: parentIndex, page: parentPage(parentData.parent), id: parentData.id, record: parentData.encode())
        }
    }
    
    public func deleteFolder(_ parents: [String], name: String) throws {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        let parentPage = self.parentPage(parent)
        
        guard let parentData: DatabaseParentCodec = try writer.get(name: parentIndex, page: parentPage, filter: { k, r in try parentUniqueFilter(r, parent: parent, name: name, file: false) }, decode: DatabaseParentCodec.init) else { throw DatabaseFileSystemError.notFoundParentAtPage }
        
        writer.delete(name: folderTable, page: folderPage(parentData.childId), id: parentData.childId)
        writer.delete(name: parentIndex, page: parentPage, id: parentData.id)
    }
    
    public func renameFolder(_ parents: [String], from: String, to: String) throws {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        let parentPage = self.parentPage(parent)
        
        guard let parentData: DatabaseParentCodec = try writer.get(name: parentIndex, page: parentPage, filter: { k, r in try parentUniqueFilter(r, parent: parent, name: from, file: false) }, decode: DatabaseParentCodec.init) else { throw DatabaseFileSystemError.notFoundParentAtPage }
        
        let folderData = DatabaseFolderCodec(id: parentData.childId, name: to)
        let newParentData = DatabaseParentCodec(id: parentData.id, parent: parentData.parent, name: to, childId: parentData.childId)
        
        writer.update(name: folderTable, page: folderPage(parentData.childId), id: parentData.childId, record: folderData.encode())
        writer.update(name: parentIndex, page: parentPage, id: parentData.id, record: newParentData.encode())
        
        let oldPath = parent.components().appendAndReturn(from).reducePath()
        let newPath = parent.components().appendAndReturn(to).reducePath()
        let oldPathPage = self.parentPage(oldPath)
        for pathData in try writer.list(name: parentIndex, page: oldPathPage, filter: { k,r in
            try DatabaseParentCodec(r).parent.hasPrefix(oldPath)
        }, decode: DatabaseParentCodec.init) {
            let oldParent = pathData.parent
            let parent = newPath + oldParent.substring(from: oldParent.index(oldParent.startIndex, offsetBy: oldPath.characters.count))
            let data = DatabaseParentCodec(id: pathData.id, parent: parent, name: pathData.name, childId: pathData.childId, dataId: pathData.dataId)
            writer.delete(name: parentIndex, page: oldPathPage, id: pathData.id)
            writer.insert(name: parentIndex, page: self.parentPage(parent), id: pathData.id, record: data.encode())
        }
    }
    
    public func writeFile(_ parents: [String], name: String, json: Json) throws {
        try checkFolder(parents)
        
        let parent = parents.reducePath()
        let parentPage = self.parentPage(parent)
        
        guard let parentData: DatabaseParentCodec = try writer.get(name: parentIndex, page: parentPage, filter: { k, r in try parentUniqueFilter(r, parent: parent, name: name, file: true) }, decode: DatabaseParentCodec.init) else { throw DatabaseFileSystemError.notFoundParentAtPage }
        
        guard let dataId = parentData.dataId else { throw DatabaseFileSystemError.resourceIsNotAFile }
        
        let dataData = DatabaseDataCodec(id: dataId, json: json)
        writer.update(name: dataTable, page: dataPage(dataId), id: dataId, record: try dataData.encode())
    }
    
}
