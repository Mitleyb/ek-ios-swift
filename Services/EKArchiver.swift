//
//  Archiver.swift
//  Dating
//
//  Created by Eilon Krauthammer on 23/01/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Foundation


struct Archiver {
    enum Directory: String {
        /// Variable.
        case images, chats, messages, wall
        
        fileprivate var directoryURL: URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(rawValue)
        }
    }
    
    let directory: Directory
    
    public func itemExists(forKey key: String) -> Bool {
        FileManager.default.fileExists(atPath:
            self.directory.directoryURL.appendingPathComponent(fn(key)).path)
    }
    
    public func put<T: Encodable>(_ item: T, forKey key: String, inSubdirectory subdir: String? = nil) throws {
        if !FileManager.default.fileExists(atPath: directory.directoryURL.appendingPathComponent(subdir ?? directory.rawValue).path) {
            // Directory doesn't exist.
            try createDirectory(extension: subdir ?? directory.rawValue)
        }
        
        let data = try JSONEncoder().encode(item)
        let path = self.directory.directoryURL.appendingPathComponent(subdir ?? directory.rawValue).appendingPathComponent(fn(key)).path
        NSKeyedArchiver.archiveRootObject(data, toFile: path)
    }
    
    public func put(data: Data, forKey key: String) throws {
        if !FileManager.default.fileExists(atPath: directory.directoryURL.path) {
            // Directory doesn't exist.
            try createDirectory()
        }
        
        let path = self.directory.directoryURL.appendingPathComponent(fn(key)).path
        NSKeyedArchiver.archiveRootObject(data, toFile: path)
    }
    
    public func get<T: Decodable>(itemForKey key: String, ofType _: T.Type) -> T? {
        let path = self.directory.directoryURL.appendingPathComponent(fn(key)).path
        guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Data else { return .none }
        guard T.self != Data.self else { return data as? T }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    public func all<T: Decodable>(_: T.Type, pathExtension: String? = nil) throws -> [T]? {
        let contents = try FileManager.default.contentsOfDirectory(at: directory.directoryURL.appendingPathComponent(pathExtension ?? directory.rawValue), includingPropertiesForKeys: nil, options: [])
        return contents.compactMap {
            let encoded = NSKeyedUnarchiver.unarchiveObject(withFile: $0.path) as? Data
            return try? JSONDecoder().decode(T.self, from: encoded ?? .init())
        }
    }
    
    public func removeAll(extension ext: String? = nil) throws {
        let url = directory.directoryURL.appendingPathComponent(ext ?? directory.rawValue)
        try FileManager.default.removeItem(at: url)
    }
    
    /// File name without extensions
    private func fn(_ key: String) -> String {
        key.filter { $0 != "." }
    }
    
    private func createDirectory(extension ext: String? = nil) throws {
        try FileManager.default.createDirectory(atPath: directory.directoryURL.appendingPathComponent(ext ?? "").path, withIntermediateDirectories: true, attributes: nil)
    }
    
}
