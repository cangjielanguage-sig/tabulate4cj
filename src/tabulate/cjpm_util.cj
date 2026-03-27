package tabulate4cj.tabulate

import cangjie_toml.cangjie_toml.*
import std.io.*
import std.env.*
import std.fs.*
import std.regex.*
import std.collection.*
import stdx.serialization.serialization.*

class CjpmLock <: Serializable<CjpmLock> {
    public CjpmLock(
        public var version: Int64,
        public var requires: HashMap<String, Require>
    ) {}
    public func serialize(): DataModel {
        return DataModelStruct().add(field("version", version)).add(field("requires", requires))
    }
    public static func deserialize(dm: DataModel): CjpmLock {
        let dms = match (dm) {
            case d: DataModelStruct => d
            case _ => throw Exception("this data is not DataModelStruct")
        }
        return CjpmLock(
            Int64.deserialize(dms.get("version")),
            HashMap<String, Require>.deserialize(dms.get("requires"))
        )
    }
}

class Require <: Serializable<Require> {
    public Require(
        public var commitId: String,
        public var git: String
    ) {}
    public func serialize(): DataModel {
        return DataModelStruct().add(field<String>("commitId", commitId)).add(field<String>("git", git))
    }
    public static func deserialize(dm: DataModel): Require {
        let dms = match (dm) {
            case d: DataModelStruct => d
            case _ => throw Exception("this data is not DataModelStruct")
        }
        return Require(
            String.deserialize(dms.get("commitId")),
            String.deserialize(dms.get("git"))
        )
    }
}

func getCjpmPath(module: String): Path {
    // toml4cj 仅支持读取扩展名为 .toml 的文件
    let cjpmLock = DataModel.fromTomlFile("cjpm.lock") |> CjpmLock.deserialize
    let commitId = cjpmLock.requires[module].commitId
    return getHomeDirectory()
        .join(Path(".cjpm"))
        .join(Path("git"))
        .join(module)
        .join(commitId)
}

public func getRootPath(path: String, module!: String = ""): Path {
    // 仅从当前目录获取文件
    if (module == "") {
        return Path(path)
    }

    // 根据 cjpm.lock 内的源码目录获取文件，如获取不到则从当前目录获取
    try {
        return getCjpmPath(module).join(path)
    } catch (_: Exception) {
        return Path(path)
    }
}

public func readTable(fileName: String, fathPath!: String = "_tests"): String {
    var filePath = Path(fathPath).join(Path(fileName))
    if (!exists(filePath)) {
        filePath = getRootPath(filePath.toString(), module: "tabulate4cj")
    }
    var res = ""
    try (reader = StringReader(File(filePath, OpenMode.Read))) {
        res = reader.readToEnd()
    }
    return res
}
