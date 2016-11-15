//
//  PhotoAPI.swift
//  InspiratoSearch
//
//  Created by Salomon Valverde on 11/11/16.
//  Copyright © 2016 Inspirato Inc. All rights reserved.
//

import Foundation
import Alamofire
import UnboxedAlamofire

typealias Completion = ([Photo]) -> ()
typealias SearchResultCompletion = (SearchResult) -> ()

final class PhotoAPI {
    
    static let shared = PhotoAPI()
    
    private let apiBaseURL = "https://api.500px.com/v1/"
    
    private let defaultParams = [
        "consumer_key": "L1Yj9o68dZub8KbSSYEdCrQG5G4tapkehKgqYVKt"
    ]
    
    // MARK: Public methods
    
    func search(keyword term: String, page: String = "1", completion: SearchResultCompletion?) {
        
        let urlParams = [
            "term": term,
            "page": page
        ]
        get(endpoint: "photos/search", parameters: urlParams, completion: completion)
    }
    
    // MARK: Convenience methods
    
    private func get(endpoint: String, parameters: Parameters?, completion: SearchResultCompletion?) {
        request(endpoint: endpoint,
                method: .get,
                encoding: URLEncoding.default,
                parameters: parameters,
                completion: completion
        )
    }
    

    private func post(endpoint: String, parameters: Parameters?, completion: SearchResultCompletion?) {
        request(endpoint: endpoint,
                method: .post,
                encoding: JSONEncoding.default,
                parameters: parameters,
                completion: completion
        )
    }
    
    private func allParameters(_ parameters: Parameters?) -> Parameters? {
        var params = parameters
        if params != nil {
            // merge default params
            for (key, value) in defaultParams {
                params!.updateValue(value, forKey: key)
            }
        } else {
            params = defaultParams
        }
        return params
    }
    
    private func request(endpoint: String, method: HTTPMethod, encoding: ParameterEncoding, parameters: Parameters?, completion: SearchResultCompletion?) {
        
        let url = apiBaseURL + endpoint
        let urlParams = allParameters(parameters)
        Alamofire.request(url, method: method, parameters: urlParams, encoding: encoding).validate(statusCode: 200..<300).responseObject { (response: DataResponse<SearchResult>) in
            print("PhotoAPI: \(response.request?.url)")
            switch response.result {
            case .success(let searchResult):
                completion?(searchResult)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}
