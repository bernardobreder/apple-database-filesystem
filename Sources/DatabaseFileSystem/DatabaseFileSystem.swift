//
//  DatabaseFileSystem.swift
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

public class DatabaseFileSystem {
    
    public init() {}
    
    public func read<T>(reader: DataStoreReader, _ callback: (DatabaseFileSystemReader) throws -> T) throws -> T {
        return try callback(DatabaseFileSystemReader(reader: reader))
    }
    
    public func write(writer: DataStoreWriter, _ callback: (DatabaseFileSystemWriter) throws -> Void) throws {
        try callback(DatabaseFileSystemWriter(writer: writer))
    }
    
}

public enum DatabaseFileSystemError: Error {
    case lastPathNotAName
    case notFoundPathAtPage
    case notFoundParentAtPage
    case resourceIsNotAFile
    case decodeUnknown(String)
    case parentFolderNotFound(String)
    case fileAlreadyExist(String)
    case alreadyFolderWithThisName([String], String)
    case alreadyFileWithThisName([String], String)
}
