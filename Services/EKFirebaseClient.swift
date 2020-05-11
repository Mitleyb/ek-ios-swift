//
//  FirebaseClient.swift
//  Dashfolio
//
//  Created by Eilon Krauthammer on 08/05/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Firebase
import SweeterSwift

/// This client helps with writing Codable conforming values to the Firebase Realtime Database.
/// Additionally - this service provides easy Firebase Storage handling.
struct FirebaseClient {
    enum StorageDirectory: String { case projects, testimonials, media, topLevel }
    
    /// Variable directory values.
    enum RealtimeDirectory: String { case portfolio, about, inspiration }
    
    static let storageReference = Storage.storage().reference()
    static let realtimeReference = Database.database().reference()
        
    typealias ErrorHandler = (Error?) -> Void
    
    let realtimeDirectory: RealtimeDirectory
    
    // MARK: - Realtime Database
    
    public func set<T: Encodable>(_ object: T, forChildPath path: String, completion: ErrorHandler?) {
        Self.realtimeReference.child(realtimeDirectory.rawValue).child(path).setValue(object.dictionary) { (error, _) in
            completion?(error)
        }
    }
    
    public func get<T: Decodable>(objectByType _: T.Type, fromChildPath path: String, completion: @escaping (T?) -> Void) {
        Self.realtimeReference.child(realtimeDirectory.rawValue).child(path).observeSingleEvent(of: .value) { snapshot in
            guard
                let nsDict = snapshot.value as? NSDictionary,
                let dictionary = nsDict as? Dictionary<String, Any>
            else {
                print("Failed to grab dictionary from snapshot.")
                completion(.none); return
            }
            
            completion(T(dictionary: dictionary))
        }
    }
    
    public func getArray<T: Decodable>(objectByType _: T.Type, completion: @escaping ([T]?) -> Void) {
        Self.realtimeReference.child(realtimeDirectory.rawValue).observeSingleEvent(of: .value) { snapshot in
            guard
                let nsDict = snapshot.value as? NSDictionary,
                let dictionary = nsDict as? Dictionary<String, Any>
            else {
                print("Failed to grab dictionary from snapshot.")
                completion(.none); return
            }
            
            completion(dictionary.compactMap { (_, value) in
                if let dictionary = value as? [String : Any] {
                    return T(dictionary: dictionary)
                }
                return .none
            })
        }
    }
    
    public func remove(in path: String, completion: ErrorHandler?) {
        Self.realtimeReference.child(realtimeDirectory.rawValue).child(path).removeValue { (error, _) in
            completion?(error)
        }
    }
    
    // MARK: - Storage
    
    static func upload(_ image: UIImage, toDirectory dir: StorageDirectory, forKey key: String, completion: ((URL?) -> Void)?) {
        guard let data = image.pngData() else { print("Image Error"); return }
        let child = storageReference.child("\(dir.rawValue)/\(key)")
        child.putData(data, metadata: nil) { metadata, error in
            guard error == nil else { completion?(nil); return }
            child.downloadURL { url, error in
                completion?(url)
            }
        }
    }
    
    static func downloadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(.none)
                }
            }
        }
    }
}
