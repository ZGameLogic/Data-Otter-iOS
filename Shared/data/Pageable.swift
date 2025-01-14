//
//  Pageable.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 1/11/25.
//

import Foundation

struct PageableData<T: Codable>: Codable {
    let content: [T]
    let pageable: Pageable
    let last: Bool
    let totalPages: Int64
    let totalElements: Int64
    let first: Bool
    let size: Int64
    let number: Int64
    let sort: Sort
    let numberOfElements: Int64
    let empty: Bool
    
}

struct Pageable: Codable {
    let pageNumber: Int64
    let pageSize: Int64
    let sort: Sort
    let offest: Int64
    let paged: Bool
    let unpaged: Bool
}

struct Sort: Codable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}
