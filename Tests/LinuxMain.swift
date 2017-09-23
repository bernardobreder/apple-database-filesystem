//
//  DatabaseFileSystemTests.swift
//  DatabaseFileSystem
//
//  Created by Bernardo Breder.
//
//

import XCTest
@testable import DatabaseFileSystemTests

extension DatabaseFileSystemTests {

	static var allTests : [(String, (DatabaseFileSystemTests) -> () throws -> Void)] {
		return [
			("testCreateFile", testCreateFile),
			("testCreateFolder", testCreateFolder),
			("testDeleteFile", testDeleteFile),
			("testDeleteFolder", testDeleteFolder),
			("testExistFile", testExistFile),
			("testListDeep", testListDeep),
			("testRenameFile", testRenameFile),
			("testRenameFolder", testRenameFolder),
			("testRollback", testRollback),
			("testWriteJson", testWriteJson),
			("testWriteRenameJson", testWriteRenameJson),
		]
	}

}

extension DatabaseFileSystemWriterTests {

	static var allTests : [(String, (DatabaseFileSystemWriterTests) -> () throws -> Void)] {
		return [
			("testRewriteFile", testRewriteFile),
			("testRewriteFileButAFolder", testRewriteFileButAFolder),
			("testRewriteFolderAndError", testRewriteFolderAndError),
			("testRewriteFolderButAFile", testRewriteFolderButAFile),
		]
	}

}

XCTMain([
	testCase(DatabaseFileSystemTests.allTests),
	testCase(DatabaseFileSystemWriterTests.allTests),
])

