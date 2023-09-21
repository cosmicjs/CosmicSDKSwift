//
//  File.swift
//  
//
//  Created by Karl Koch on 19/09/2023.
//

import Foundation

public struct CosmicEndpointProvider {
    public enum API {
        case find
        case findOne
        case insertOne
        case updateOne
        case deleteOne
    }
    
    public enum Source {
        case cosmic
    }
    
    public enum Status: String {
        case published
        case any
    }

    public enum Sorting: String {
        case created_at
        case _created_at = "-created_at"
        case modified_at
        case _modified_at = "-modified_at"
        case random
        case order
    }
    
    public let source: Source
    public let status: Status
    public let sorting: Sorting
    
    public init(source: CosmicEndpointProvider.Source, status: Status = .published, sorting: Sorting = .order) {
        self.source = source
        self.status = status
        self.sorting = sorting
    }
    
    func getPath(api: API, id: String? = nil, bucket: String, type: String, read_key: String, write_key: String?, props: String? = nil, limit: String? = nil, status: Status? = nil, sort: Sorting? = nil, metadata: [String: AnyCodable]? = nil) -> (String, [String: String?]) {
        let write_key = write_key.map { "&write_key=\($0)" } ?? ""
        
        switch source {
        case .cosmic:
            switch api {
            case .find:
                var queryComponents: [String: String] = ["type": type]
                if let status = status {
                    queryComponents["status"] = status.rawValue
                }
                if let sort = sort {
                    queryComponents["sort"] = sort.rawValue
                }
                let queryData = try! JSONSerialization.data(withJSONObject: queryComponents, options: [])
                let queryString = String(data: queryData, encoding: .utf8)!
                return ("/v3/buckets/\(bucket)/objects", ["pretty": "true", "query": queryString, "read_key": read_key, "props": props, "limit": limit, "write_key": write_key])
            case .findOne, .updateOne, .deleteOne:
                guard let id = id else { fatalError("Missing ID for \(api) operation") }
                return ("/v3/buckets/\(bucket)/objects/\(id)", [:])
            case .insertOne:
                return ("/v3/buckets/\(bucket)/objects/", [:])
            }
        }
    }

    func getMethod(api: API) -> String {
        switch source {
        case .cosmic:
            switch api {
            case .find, .findOne:
                return "GET"
            case .insertOne:
                return "POST"
            case .updateOne:
                return "PATCH"
            case .deleteOne:
                return "DELETE"
            }
        }
    }
}
