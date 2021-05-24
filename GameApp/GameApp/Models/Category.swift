//
//  Category.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//
import Foundation

// MARK: - Category
struct Category: Codable {
    let count: Int?
    let next, previous: String?
    let results: [CategoryPlatform]?
}

// MARK: - CategoryResult
struct CategoryResult: Codable {
    let id: Int?
    let name, slug: String?
    let platforms: [CategoryPlatform]?
}

// MARK: - CategoryPlatform
struct CategoryPlatform: Codable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?
    let image, yearStart, yearEnd: String?
}
