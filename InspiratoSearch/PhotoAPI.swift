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

typealias Completion = () -> ()

final class PhotoAPI {
    
    static let sharedInstance = PhotoAPI()
    
    private let apiBaseURL = "https://api.500px.com/v1/"
    
    private let defaultParams = [
        "consumer_key": "L1Yj9o68dZub8KbSSYEdCrQG5G4tapkehKgqYVKt"
    ]
    
    func searchPhotos(keyword term: String, page: String?, completion: Completion?) {
        let urlParams = [
            "term": term,
            "page": page
        ]
        get(endpoint: "photos/search", parameters: urlParams, completion: nil)
    }
    
    // Convenience method to perform a GET request on an API endpoint.
    private func get(endpoint: String, parameters: Parameters?, completion: Completion?) {
        request(endpoint: endpoint,
                method: .get,
                encoding: JSONEncoding.default,
                parameters: parameters,
                completion: completion
        )
    }
    
    // Convenience method to perform a POST request on an API endpoint.
    private func post(endpoint: String, parameters: Parameters?, completion: Completion?) {
        request(endpoint: endpoint,
                method: .post,
                encoding: JSONEncoding.default,
                parameters: parameters,
                completion: completion
        )
    }
    
    // Perform a request on an API endpoint using Alamofire.
    private func request(endpoint: String, method: HTTPMethod, encoding: ParameterEncoding, parameters: Parameters?, completion: Completion?) {
        
        let urlParams = [
            "term":"computer",
            "consumer_key":"L1Yj9o68dZub8KbSSYEdCrQG5G4tapkehKgqYVKt",
            "page":"1",
        ]
        Alamofire.request("https://api.500px.com/v1/photos/search", method: .get, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    debugPrint("HTTP Response Body: \(response.data)")
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error)")
                }
        }
    }
    
    private func allParameters(_ parameters: Parameters?) -> Parameters? {
        var params = parameters
        if params != nil {
            // Add default params
            for (key, value) in defaultParams {
                params!.updateValue(value, forKey: key)
            }
        } else {
            params = defaultParams
        }
        
        return params
    }
}
