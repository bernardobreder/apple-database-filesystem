//
//  DatabaseFileSystem.swift
//  DatabaseFileSystem
//
//  Created by Bernardo Breder on 17/01/17.
//
//

import XCTest
@testable import DataStore
@testable import DatabaseFileSystem
@testable import Json

class DatabaseFileSystemTests: XCTestCase {
    
    func testListDeep() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder([], name: "c")
            try wfs.createFolder(["b"], name: "d")
            try wfs.createFolder(["b", "d"], name: "e")
            try wfs.createFile([], name: "_.txt")
            try wfs.createFile(["a"], name: "a.txt")
            try wfs.createFile(["b"], name: "b.txt")
            try wfs.createFile(["c"], name: "c.txt")
            try wfs.createFile(["b", "d"], name: "d.txt")
            try wfs.createFile(["b", "d", "e"], name: "e.txt")
            } }
        
        XCTAssertEqual(["/a", "/b", "/b/d", "/b/d/e", "/c"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([], deep: true) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"], deep: true) }.folders.sorted() })
        XCTAssertEqual(["/b/d", "/b/d/e"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"], deep: true) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"], deep: true) }.folders.sorted() })
        XCTAssertEqual(["/b/d/e"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"], deep: true) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"], deep: true) }.folders.sorted() })
        
        XCTAssertEqual(["/_.txt", "/a/a.txt", "/b/b.txt", "/b/d/d.txt", "/b/d/e/e.txt", "/c/c.txt"
            ], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([], deep: true) }.files.sorted() })
        XCTAssertEqual(["/a/a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"], deep: true) }.files.sorted() })
        XCTAssertEqual(["/b/b.txt", "/b/d/d.txt", "/b/d/e/e.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"], deep: true) }.files.sorted() })
        XCTAssertEqual(["/c/c.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"], deep: true) }.files.sorted() })
        XCTAssertEqual(["/b/d/d.txt", "/b/d/e/e.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"], deep: true) }.files.sorted() })
        XCTAssertEqual(["/b/d/e/e.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"], deep: true) }.files.sorted() })
    }
    
    func testCreateFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder([], name: "c")
            try wfs.createFolder(["b"], name: "d")
            try wfs.createFolder(["b", "d"], name: "e")
            } }
        
        XCTAssertEqual(["a", "b", "c"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual(["e"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
    }
    
    func testCreateFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder([], name: "c")
            try wfs.createFolder(["b"], name: "d")
            try wfs.createFolder(["b", "d"], name: "e")
            } }
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFile([], name: "_.txt")
            try wfs.createFile(["a"], name: "a.txt")
            try wfs.createFile(["b"], name: "b.txt")
            try wfs.createFile(["c"], name: "c.txt")
            try wfs.createFile(["b", "d"], name: "d.txt")
            try wfs.createFile(["b", "d", "e"], name: "e.txt")
            } }
        
        XCTAssertEqual(["a", "b", "c"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual(["e"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        XCTAssertEqual(["_.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual(["b.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual(["c.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual(["d.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual(["e.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
    }
    
    func testDeleteFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder([], name: "c")
            try wfs.createFolder(["b"], name: "d")
            try wfs.createFolder(["b", "d"], name: "e")
            try wfs.createFile([], name: "_.txt")
            try wfs.createFile(["a"], name: "a.txt")
            try wfs.createFile(["b"], name: "b.txt")
            try wfs.createFile(["c"], name: "c.txt")
            try wfs.createFile(["b", "d"], name: "d.txt")
            try wfs.createFile(["b", "d", "e"], name: "e.txt")
            } }
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFile(["b", "d", "e"], name: "e.txt")
            } }
        
        XCTAssertEqual(["_.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual(["b.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual(["c.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual(["d.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFile(["b", "d"], name: "d.txt")
            } }
        
        XCTAssertEqual(["_.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual(["b.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual(["c.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFile(["b"], name: "b.txt")
            } }
        
        XCTAssertEqual(["_.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual(["c.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFile(["c"], name: "c.txt")
            } }
        
        XCTAssertEqual(["_.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFile(["a"], name: "a.txt")
            } }
        
        XCTAssertEqual(["_.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFile([], name: "_.txt")
            } }
        
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
    }
    
    func testDeleteFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder([], name: "c")
            try wfs.createFolder(["b"], name: "d")
            try wfs.createFolder(["b", "d"], name: "e")
            } }
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFolder(["b", "d"], name: "e")
            } }
        
        XCTAssertEqual(["a", "b", "c"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFolder(["b"], name: "d")
            } }
        
        XCTAssertEqual(["a", "b", "c"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFolder([], name: "b")
            } }
        
        XCTAssertEqual(["a", "c"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFolder([], name: "c")
            } }
        
        XCTAssertEqual(["a"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.deleteFolder([], name: "a")
            } }
        
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
    }
    
    func testRenameFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder([], name: "c")
            try wfs.createFolder(["b"], name: "d")
            try wfs.createFolder(["b", "d"], name: "e")
            try wfs.createFile([], name: "_.txt")
            try wfs.createFile(["a"], name: "a.txt")
            try wfs.createFile(["b"], name: "b.txt")
            try wfs.createFile(["c"], name: "c.txt")
            try wfs.createFile(["b", "d"], name: "d.txt")
            try wfs.createFile(["b", "d", "e"], name: "e.txt")
            } }
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.renameFile(["b", "d", "e"], from: "e.txt", to: "E.txt")
            try wfs.renameFile(["b", "d"], from: "d.txt", to: "D.txt")
            try wfs.renameFile(["b"], from: "b.txt", to: "B.txt")
            try wfs.renameFile(["c"], from: "c.txt", to: "C.txt")
            try wfs.renameFile(["a"], from: "a.txt", to: "A.txt")
            try wfs.renameFile([], from: "_.txt", to: "*.txt")
            } }
        
        XCTAssertEqual(["a", "b", "c"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual(["d"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual(["e"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        XCTAssertEqual(["*.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual(["A.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.files.sorted() })
        XCTAssertEqual(["B.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.files.sorted() })
        XCTAssertEqual(["C.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.files.sorted() })
        XCTAssertEqual(["D.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.files.sorted() })
        XCTAssertEqual(["E.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.files.sorted() })
    }
    
    func testRenameFolder() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder([], name: "c")
            try wfs.createFolder(["b"], name: "d")
            try wfs.createFolder(["b", "d"], name: "e")
            try wfs.createFolder([], name: "f")
            try wfs.createFolder(["f"], name: "g")
            try wfs.createFolder(["f", "g"], name: "h")
            try wfs.createFile([], name: "_.txt")
            try wfs.createFile(["a"], name: "a.txt")
            try wfs.createFile(["b"], name: "b.txt")
            try wfs.createFile(["c"], name: "c.txt")
            try wfs.createFile(["b", "d"], name: "d.txt")
            try wfs.createFile(["b", "d", "e"], name: "e.txt")
            } }
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.renameFolder([], from: "a", to: "A")
            try wfs.renameFolder([], from: "b", to: "B")
            try wfs.renameFolder([], from: "c", to: "C")
            try wfs.renameFolder(["B", "d"], from: "e", to: "E")
            try wfs.renameFolder(["B"], from: "d", to: "DD")
            try wfs.renameFolder(["f"], from: "g", to: "G")
            try wfs.renameFolder([], from: "f", to: "F")
            try wfs.renameFolder(["F", "G"], from: "h", to: "H")
            } }
        
        XCTAssertEqual(["A", "B", "C", "F"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["a"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["c"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["f"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["b", "d", "e"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["d"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["e"]) }.folders.sorted() })
        
        XCTAssertEqual(["A", "B", "C", "F"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["A"]) }.folders.sorted() })
        XCTAssertEqual(["DD"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["B"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["C"]) }.folders.sorted() })
        XCTAssertEqual(["G"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["F"]) }.folders.sorted() })
        XCTAssertEqual(["H"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["F", "G"]) }.folders.sorted() })
        XCTAssertEqual(["E"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["B", "DD"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["B", "DD", "E"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["D"]) }.folders.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["E"]) }.folders.sorted() })
        
        XCTAssertEqual(["_.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["A"]) }.files.sorted() })
        XCTAssertEqual(["b.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["B"]) }.files.sorted() })
        XCTAssertEqual(["c.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["C"]) }.files.sorted() })
        XCTAssertEqual(["d.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["B", "DD"]) }.files.sorted() })
        XCTAssertEqual(["e.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["B", "DD", "E"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["DD"]) }.files.sorted() })
        XCTAssertEqual([], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list(["E"]) }.files.sorted() })
    }
    
    func testWriteJson() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFile([], name: "a.txt")
            try wfs.writeFile([], name: "a.txt", json: Json("ação"))
            } }
        try db.read { reader in try dfs.read(reader: reader) { rfs in
            XCTAssertEqual("ação", try rfs.readFile([], name: "a.txt").string!)
            } }
    }
    
    func testWriteRenameJson() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFolder([], name: "b")
            try wfs.createFolder(["b"], name: "c")
            try wfs.createFile(["a"], name: "a.txt")
            try wfs.createFile(["b"], name: "b.txt")
            try wfs.createFile(["b", "c"], name: "c.txt")
            try wfs.writeFile(["a"], name: "a.txt", json: Json("ação"))
            try wfs.writeFile(["b"], name: "b.txt", json: Json("reação"))
            try wfs.writeFile(["b", "c"], name: "c.txt", json: Json("teste"))
            } }
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.renameFolder([], from: "a", to: "A")
            XCTAssertNil(try? wfs.readFile(["a"], name: "a.txt"))
            XCTAssertEqual("ação", try wfs.readFile(["A"], name: "a.txt").string!)
            XCTAssertEqual("reação", try wfs.readFile(["b"], name: "b.txt").string!)
            XCTAssertEqual("teste", try wfs.readFile(["b", "c"], name: "c.txt").string!)
            
            try wfs.renameFile(["b"], from: "b.txt", to: "B.txt")
            XCTAssertNil(try? wfs.readFile(["a"], name: "a.txt"))
            XCTAssertNil(try? wfs.readFile(["b"], name: "b.txt"))
            XCTAssertEqual("ação", try wfs.readFile(["A"], name: "a.txt").string!)
            XCTAssertEqual("reação", try wfs.readFile(["b"], name: "B.txt").string!)
            XCTAssertEqual("teste", try wfs.readFile(["b", "c"], name: "c.txt").string!)
            
            try wfs.renameFolder([], from: "b", to: "B")
            XCTAssertNil(try? wfs.readFile(["a"], name: "a.txt"))
            XCTAssertNil(try? wfs.readFile(["b"], name: "b.txt"))
            XCTAssertNil(try? wfs.readFile(["b", "c"], name: "c.txt"))
            XCTAssertEqual("ação", try wfs.readFile(["A"], name: "a.txt").string!)
            XCTAssertEqual("reação", try wfs.readFile(["B"], name: "B.txt").string!)
            XCTAssertEqual("teste", try wfs.readFile(["B", "c"], name: "c.txt").string!)
            } }
    }
    
    func testExistFile() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()
        
        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFile([], name: "a.txt")
            } }
        
        try db.read { reader in try dfs.read(reader: reader) { rfs in
            XCTAssertTrue(try rfs.existFolder([], name: "a"))
            XCTAssertTrue(try rfs.existFile([], name: "a.txt"))
            XCTAssertFalse(try rfs.existFolder([], name: "a.txt"))
            XCTAssertFalse(try rfs.existFile([], name: "a"))
            XCTAssertFalse(try rfs.existFolder([], name: "b"))
            XCTAssertFalse(try rfs.existFile([], name: "b.txt"))
            } }
    }
    
    func testRollback() throws {
        let fs = MemoryFileSystem()
        let db = try DataStore(fileSystem: DataStoreFileSystem(folder: fs.home()))
        let dfs = DatabaseFileSystem()

        try db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "a")
            try wfs.createFile([], name: "a.txt")
            } }
        
        XCTAssertEqual(["a"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
        
        try? db.write { writer in try dfs.write(writer: writer) { wfs in
            try wfs.createFolder([], name: "b")
            try wfs.createFile([], name: "b.txt")
            throw DatabaseFileSystemError.resourceIsNotAFile
            } }
        
        XCTAssertEqual(["a"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.folders.sorted() })
        XCTAssertEqual(["a.txt"], try db.read { reader in try dfs.read(reader: reader) { rfs in try rfs.list([]) }.files.sorted() })
    }

}

