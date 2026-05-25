//
//  HTTPClientResult.swift
//  EssentialFeed
//
//  Created by ali naveed on 25/05/2026.
//


import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
    
}
public protocol HttpClient {
    func get(from url: URL,completion: @escaping (HTTPClientResult) -> Void)
}
