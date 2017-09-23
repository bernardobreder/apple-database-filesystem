//
//  DatabaseFileSystemWriterTests.swift
//  DatabaseFileSystem
//
//  Created by Bernardo Breder on 02/02/17.
//
//

import XCTest
@testable import DataStore
@testable import DatabaseFileSystem
@testable import Json

class DatabaseFileSystemWriterTests: XCTestCase {
    
    func testRewriteFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFile([], name: "a.txt", json: Json(1))
            } }
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFile([], name: "a.txt", json: Json(2))
            } }
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            XCTAssertEqual(2, try wfs.readFile([], name: "a.txt").int)
            } }
    }
    
    func testRewriteFolderAndError() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            } }
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            } }
    }
    
    func testRewriteFileButAFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            } }
        
        XCTAssertNil(try? db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFile([], name: "a", json: Json(1))
            } })
    }
    
    func testRewriteFolderButAFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFile([], name: "a", json: Json(1))
            } }
        
        XCTAssertNil(try? db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            } })
    }
    
}
