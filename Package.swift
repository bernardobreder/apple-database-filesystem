//
//  Package.swift
//  DatabaseFileSystem
//
//

import PackageDescription

let package = Package(
	name: "DatabaseFileSystem",
	targets: [
		Target(name: "DatabaseFileSystem", dependencies: ["DataStore", "Json"]),
		Target(name: "Array", dependencies: []),
		Target(name: "AtomicValue", dependencies: []),
		Target(name: "DataStore", dependencies: ["Array", "AtomicValue", "Dictionary", "FileSystem", "IndexLiteral", "Json", "Literal", "Optional", "Regex"]),
		Target(name: "Dictionary", dependencies: []),
		Target(name: "FileSystem", dependencies: []),
		Target(name: "IndexLiteral", dependencies: []),
		Target(name: "Json", dependencies: ["Array", "IndexLiteral", "Literal"]),
		Target(name: "Literal", dependencies: []),
		Target(name: "Optional", dependencies: []),
		Target(name: "Regex", dependencies: []),
	]
)

