//
//  FileCas.swift
//  Tasker
//
//  Created by Rodion Akhmedov on 5/6/25.
//
import Foundation

public class FileCas: Cas {
    
    // private:
    
    private let dir: URL
    
    private func path(_ id: String) -> URL {
        dir.appendingPathComponent(id)
    }
    
    // public:
    
    public init(_ dir: URL) {
        self.dir = dir
    }
    
    public func id(_ data: Data) -> String {
        data.sha256Id()
    }
    
    public func add(_ data: Data) throws -> String {
        let id = id(data)
        try data.write(to: path(id))
        return id
    }
    
    public func get(_ id: String) -> Data? {
        // TODO: check errors. if the file doesn't exist, return nil
        // otherwise, throw the error
        try? Data(contentsOf: path(id))
    }
    
    public func list() throws -> [String] {
        let result = try FileManager.default.contentsOfDirectory(
            at: dir, includingPropertiesForKeys: nil
        )
            .map { $0.lastPathComponent }
        return result
    }
}
struct ModelStruct<T> {
    var mutable: Mutable
    var value: T
}

public class Model<T>: Hashable, Identifiable {
    // internal:
    var s: ModelStruct<T>
    init(_ s: ModelStruct<T>) {
        self.s = s
    }
    // public:
    public static func initial(_ value: T) -> Model {
        Model(ModelStruct(mutable: Mutable.initial(), value: value))
    }
    public var value: T {
        get { s.value }
        set { s.value = newValue }
    }
    
    // Hashable:
    
    public static func == (lhs: Model, rhs: Model) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
extension Cas {
    @discardableResult
    public func saveJsonModel<T: Encodable>(_ model: Model<T>) throws -> String? {
        try saveJson(model.s.mutable, model.s.value)
    }
    
    public func loadJsonModel<T: Decodable>(_ mutable: Mutable) throws -> Model<T>? {
        guard let value: T = try loadJson(mutable) else {
            return nil
        }
        return Model(ModelStruct(mutable: mutable, value: value))
    }
    @discardableResult
    public func deleteModel<T>(_ model: Model<T>) throws -> String? {
        try delete(model.s.mutable)
    }
}
