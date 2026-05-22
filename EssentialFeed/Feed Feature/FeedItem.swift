//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by ali naveed on 21/05/2026.
//
import Foundation

public struct FeedItem:Equatable {
    let id:UUID
    let description:String?
    let location:String?
    let imageURL:String
}
