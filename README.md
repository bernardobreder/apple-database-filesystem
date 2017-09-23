# Introdução

O componente DatabaseFileSystem é responsável por criar um sistema de arquivo baseado num banco de dados. Todos os arquivos e diretórios são armazenados num banco de dados garantindo assim uma transação.

# Exemplo

O exemplo abaixo mostra a criação um sistema de arquivo com um diretório e um arquivo com um conteúdo:

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

