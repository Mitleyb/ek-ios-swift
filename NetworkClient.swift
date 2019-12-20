//
//  NetworkingClient.swift
//  Dating
//
//  Created by Eilon Krauthammer on 13/12/2019.
//  Copyright © 2019 Eilon Krauthammer. All rights reserved.
//

import Foundation

// MARK: - Protocol

protocol Fetchable {
    static func keyPath() -> NetworkInfo.CodingKeyPath
}

struct NULL: Codable, Fetchable {
    static func keyPath() -> NetworkInfo.CodingKeyPath {
        return .null
    }
}

// MARK: - App Related - Info

struct NetworkInfo {
    enum URLPath {
        private static let urlPrefix: String = "http://iramml.com/test/dating/"
        case signIn, signUp
        case updateStatus
        /// Provide: Access token
        case fetchProfile(String)
        /// Provide: Image name
        case fetchImage(String)
        /// Provide: Params object
        case fetchUsers(Encodable)
        
        public var path: String {
            let prefix = Self.urlPrefix
            switch self {
            case .signIn:
                return "\(prefix)api/client/sign/in/index.php"
            case .signUp:
                return "\(prefix)api/client/sign/up/index.php"
            case .updateStatus:
                return "\(prefix)api/client/status/connected/index.php"
            case .fetchProfile(let accessToken):
                return "\(prefix)api/client/profile/get/index.php?token=\(accessToken)"
            case .fetchImage(let imageName):
                return "\(prefix)uploads/profile/images/\(imageName)"
            case .fetchUsers(let obj):
                guard let params = obj.dictionary?.queryString else { fatalError() }
                return "\(prefix)api/client/meeting/get/index.php?\(params)"
            }
        }
    }
    
    enum CodingKeyPath: String, CodingKey {
        case profile
        case auth = "access_token"
        case query = "users"
        case null
    }
}

// MARK: - Response

struct StatusResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case code, message
    }
    
    let code: String, message: String
}

struct NetworkResponse<T: Decodable & Fetchable> {
    enum Status: Int {
        case ok         = 200
        case badRequest = 400
    }

    public struct Container: Decodable {
        let statusResponse: StatusResponse?
        let object: T?
        
        init(from decoder: Decoder) throws {
            let c1 = try decoder.container(keyedBy: StatusResponse.CodingKeys.self)
            let c2 = try decoder.container(keyedBy: NetworkInfo.CodingKeyPath.self)
        
            self.statusResponse = .init(
                code:    try c1.decode(String.self, forKey: .code),
                message: try c1.decode(String.self, forKey: .message)
            )
            self.object = try? c2.decode(T.self, forKey: T.keyPath())
        }
    }
    
    let status: Status
    let container: Container?
    let rawData: Data?
    
    public func json() -> Any? {
        return try? JSONSerialization.jsonObject(with: self.rawData ?? .init(), options: [])
    }
    
}

// MARK: - Reqeust

/**
 This object hosts the needed data for a standard HTTP request. You can execute the request using the `execute(_:)` function.
 This object allows can convert encodable objects to the request's body and can turn the response into a decodable object.
 
 - Generics:
   - `T` - Pass in an encodable object.
   - `U` - Pass in a decodable object.
 */
struct NetworkRequest<T: Encodable, U: Decodable & Fetchable> {
    enum HTTPMethod: String {
        case get  = "GET"
        case put  = "PUT"
        case post = "POST"
    }
    
    enum RequestError: Error {
        /// Provided: Description
        case error(String)
    }
    
    /// This results returns a status code for the request along with an optional object.
    typealias Response = NetworkResponse<U>
    typealias Handler = (Result<Response, Error>) -> Void
    
    let url: URL
    let method: HTTPMethod
    let httpHeaders: [String]?
    let bodyObject: T?
    let formParams: Bool
    let multipart: Bool
    
    /// This initializer fails if the URL String given is invalid.
    /// - Parameter formParameters: Turns the body object to a query string that is sent as data. eg: `paramNameA=valueA&paramNameB=valueB`.
    /// - Parameter multipart: When chained with `formParameters = true`, the parameter is sent in a `multipart-form` style with a boundary. **Note: The object passed for encoding must be respresentable in** `[String: String]` **else the request will throw an error.**
    /// - Parameter object: The object to encode as a body.
    public init?(urlString: String, method: HTTPMethod, headers: [String]? = nil, object: T? = nil, formParameters: Bool = false, multipart: Bool = false) {
        guard let url = URL(string: urlString) else { return nil }
        self.url = url
        self.method = method
        self.httpHeaders = headers
        self.bodyObject = object
        self.formParams = formParameters
        self.multipart = multipart
    }
    
    public func execute(_ completion: @escaping Handler) {
        var request = URLRequest(url: self.url)
        request.httpMethod = self.method.rawValue
        
        if let headers = self.httpHeaders {
            headers.forEach { request.addValue($0, forHTTPHeaderField: "Content-Type") }
        }
        
        if self.method != .get {
            // Assign request body
            if formParams {
                let dictionary = self.bodyObject?.dictionary
                if multipart {
                    guard let params = dictionary as? [String: String] else {
                        let error = RequestError.error("Could not convert object to string dictionary.")
                        completion(.failure(error)); return
                    }
                    do {
                        try request.setMultipartFormData(params, encoding: .utf8)
                    } catch let error {
                        completion(.failure(error))
                    }
                } else {
                    let body = dictionary?.queryString.data(using: .utf8)
                    request.httpBody = body
                }
            } else {
                var body: Data?
                do {
                    try body = JSONEncoder().encode(self.bodyObject)
                } catch let error {
                    completion(.failure(error))
                }
                
                request.httpBody = body
            }
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let status = Response.Status(rawValue: response.statusCode) ?? .badRequest
                guard let data = data else { return }
                typealias Container = NetworkResponse<U>.Container
                var decoded: Container?
                do {
                    decoded = try JSONDecoder().decode(Container.self, from: data)
                } catch let err {
                    print("Error decoding: \n \(err)")
                }
                
                let networkResponse = Response(status: status, container: decoded, rawData: data)
                DispatchQueue.main.async {
                    completion(.success(networkResponse))
                }
            } else {
                print(response ?? "", #line)
            }
            
        }.resume()
    }
}

// MARK: - Helper Extensions

fileprivate extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key, value) in self {
            output += "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}

fileprivate extension URLRequest {
    // * Credit * - https://gist.github.com/nolanw/dff7cc5d5570b030d6ba385698348b7c
    
    enum MultipartFormDataEncodingError: Error {
        case characterSetName
        case name(String)
        case value(String, name: String)
    }
    
    /**
     Configures the URL request for `multipart/form-data`. The request's `httpBody` is set, and a value is set for the HTTP header field `Content-Type`.
     
     - Parameter parameters: The form data to set.
     - Parameter encoding: The encoding to use for the keys and values.
     
     - Throws: `MultipartFormDataEncodingError` if any keys or values in `parameters` are not entirely in `encoding`.
     
     - Note: The default `httpMethod` is `GET`, and `GET` requests do not typically have a response body. Remember to set the `httpMethod` to e.g. `POST` before sending the request.
     */
    mutating func setMultipartFormData(_ parameters: [String: String], encoding: String.Encoding) throws {
        let makeRandom = { UInt32.random(in: (.min)...(.max)) }
        let boundary = String(format: "------------------------%08X%08X", makeRandom(), makeRandom())

        let contentType: String = try {
            guard let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)) else {
                throw MultipartFormDataEncodingError.characterSetName
            }
            return "multipart/form-data; charset=\(charset); boundary=\(boundary)"
        }()
        addValue(contentType, forHTTPHeaderField: "Content-Type")

        httpBody = try {
            var body = Data()

            for (rawName, rawValue) in parameters {
                if !body.isEmpty {
                    body.append("\r\n".data(using: .utf8)!)
                }

                body.append("--\(boundary)\r\n".data(using: .utf8)!)

                guard
                    rawName.canBeConverted(to: encoding),
                    let disposition = "Content-Disposition: form-data; name=\"\(rawName)\"\r\n".data(using: encoding) else {
                    throw MultipartFormDataEncodingError.name(rawName)
                }
                body.append(disposition)

                body.append("\r\n".data(using: .utf8)!)

                guard let value = rawValue.data(using: encoding) else {
                    throw MultipartFormDataEncodingError.value(rawValue, name: rawName)
                }

                body.append(value)
            }

            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            return body
        }()
    }
}
