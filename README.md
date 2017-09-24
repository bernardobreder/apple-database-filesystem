# Introduction

The DatabaseFileSystem component is responsible for creating a file system based on a database. All files and directories are stored in a database thus ensuring a transaction.

# Example

The example below shows the creation of a file system with a directory and a file with a content:

```swift
let folder = MemoryFileSystem().home()
let dbfs = DatabaseFileSystem(folder: folder)

dbfs.write { wfs in
    try wfs.createFolder([], name: "a")
    try wfs.createFile(["a"], name: "a.txt")
    try wfs.writeFile(["a"], name: "a.txt", json: Json("test"))
}

try dbfs.read { rfs in
    print(try rfs.readFile(["a"], name: "a.txt").string!) // test
}
```

