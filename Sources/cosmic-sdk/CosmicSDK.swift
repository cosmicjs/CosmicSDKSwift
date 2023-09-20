//
//  CosmicSDK.swift
//
//
//  Created by Karl Koch on 19/09/2023.
//

import Foundation
#if canImport(FoundationNetworking) && canImport(FoundationXML)
import FoundationNetworking
import FoundationXML
#endif

public enum CosmicError: Error {
    case genericError(error: Error)
    case decodingError(error: Error)
}

public class CosmicSDKSwift {
    fileprivate let config: Config

    /// Configuration object for the client
    public struct Config {
        
        /// Initialiser
        /// - Parameter session: the session to use for network requests.
        public init(baseURL: String, endpointPrivider: CosmicEndpointProvider, session: URLSession, authorizeRequest: @escaping (inout URLRequest) -> Void) {
            self.baseURL = baseURL
            self.endpointProvider = endpointPrivider
            self.authorizeRequest = authorizeRequest
            self.session = session
        }
        let baseURL: String
        let endpointProvider: CosmicEndpointProvider
        let session:URLSession
        let authorizeRequest: (inout URLRequest) -> Void
        
        public static func makeDefaultCosmic(write_key: String) -> Self {
            .init(baseURL: "https://api.cosmicjs.com",
                  endpointPrivider: CosmicEndpointProvider(source: .cosmic),
                  session: .shared,
                  authorizeRequest: { request in
                    request.setValue("Bearer \(write_key)", forHTTPHeaderField: "Authorization")
            })
        }
    }
    
    public init(config: Config) {
        self.config = config
    }
    
    private func makeRequest(request: URLRequest, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let session = config.session
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else if let data = data {
                completionHandler(.success(data))
            }
        }
        
        task.resume()
    }
    
    private func prepareRequest<BodyType: Encodable>(_ endpoint: CosmicEndpointProvider.API, body: BodyType, id: String?, bucket: String, type: String, read_key: String, write_key: String?, props: String?, limit: String?, title: String?, slug: String?, content: String?, metadata: String?) -> URLRequest {
        var urlComponents = URLComponents(url: URL(string: config.baseURL)!, resolvingAgainstBaseURL: true)
        urlComponents?.path = config.endpointProvider.getPath(api: endpoint, id: id, bucket: bucket, type: type, read_key: read_key, write_key: write_key, props: props, limit: limit, title: title, slug: slug, content: content, metadata: metadata)
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = config.endpointProvider.getMethod(api: endpoint)
        
        config.authorizeRequest(&request)
        
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(body) {
            request.httpBody = encoded
        }
        
        return request
    }

}

extension CosmicSDKSwift {
    struct Body: Encodable {
        let type: String
        let title: String
        let content: String
        let metadata: [String]
    }
    
    public func find(with bucket: String, type: String, read_key: String, props: String?, limit: String?, completionHandler: @escaping (Result<CosmicSDK<Object>, CosmicError>) -> Void) {
        let endpoint = CosmicEndpointProvider.API.find
        let request = prepareRequest(endpoint, body: "", id: "", bucket: bucket, type: type, read_key: read_key, write_key: "", props: props, limit: limit, title: "", slug: "", content: "", metadata: "")
                
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(CosmicSDK<Object>.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    public func findOne(with bucket: String, type: String, read_key: String, props: String?, limit: String?, id: String, completionHandler: @escaping (Result<CosmicSDK<Object>, CosmicError>) -> Void) {
        let endpoint = CosmicEndpointProvider.API.findOne
        let request = prepareRequest(endpoint, body: "", id: id, bucket: bucket, type: type, read_key: read_key, write_key: "", props: props, limit: limit, title: "", slug: "", content: "", metadata: "")
                
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(CosmicSDK<Object>.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    public func insertOne(with bucket: String, type: String, read_key: String, id: String, write_key: String, props: String, limit: String?, title: String, slug: String?, content: String?, metadata: String?, completionHandler: @escaping (Result<CosmicSDK<Object>, CosmicError>) -> Void) {
        let endpoint = CosmicEndpointProvider.API.insertOne
        let body = Body(type: type, title: title, content: content ?? "", metadata: [metadata ?? ""])
        let request = prepareRequest(endpoint, body: body, id: id, bucket: bucket, type: type, read_key: read_key, write_key: write_key, props: props, limit: limit, title: title, slug: slug, content: content, metadata: metadata)
                
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(CosmicSDK<Object>.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    public func updateOne(with bucket: String, type: String, read_key: String, id:String, write_key: String, props: String, limit: String?, title: String, slug: String?, content: String?, metadata: String?, completionHandler: @escaping (Result<CosmicSDK<Object>, CosmicError>) -> Void) {
        let endpoint = CosmicEndpointProvider.API.updateOne
        let body = Body(type: type, title: title, content: content ?? "", metadata: [metadata ?? ""])
        let request = prepareRequest(endpoint, body: body, id: id, bucket: bucket, type: type, read_key: read_key, write_key: write_key, props: props, limit: limit, title: title, slug: slug, content: content, metadata: metadata)
                
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(CosmicSDK<Object>.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
    
    public func deleteOne(with bucket: String, type: String, read_key: String, write_key: String, id: String, completionHandler: @escaping (Result<CosmicSDK<Object>, CosmicError>) -> Void) {
        let endpoint = CosmicEndpointProvider.API.deleteOne
        let request = prepareRequest(endpoint, body: "", id: id, bucket: bucket, type: type, read_key: read_key, write_key: write_key, props: "", limit: "", title: "", slug: "", content: "", metadata: "")
                
        makeRequest(request: request) { result in
            switch result {
            case .success(let success):
                do {
                    let res = try JSONDecoder().decode(CosmicSDK<Object>.self, from: success)
                    completionHandler(.success(res))
                } catch {
                    completionHandler(.failure(.decodingError(error: error)))
                }
            case .failure(let failure):
                completionHandler(.failure(.genericError(error: failure)))
            }
        }
    }
}
