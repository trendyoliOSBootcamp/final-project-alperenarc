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
struct CategoryPlatform: Codable, Equatable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?
    let image, yearStart, yearEnd: String?

    init(id: Int?) {
        self.id = id
        self.name = nil
        self.slug = nil
        self.gamesCount = nil
        self.imageBackground = nil
        self.image = nil
        self.yearStart = nil
        self.yearEnd = nil
    }

    public static func == (lhs: CategoryPlatform, rhs: CategoryPlatform) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.slug == rhs.slug &&
            lhs.gamesCount == rhs.gamesCount &&
            lhs.imageBackground == rhs.imageBackground &&
            lhs.image == rhs.image &&
            lhs.yearStart == rhs.yearStart &&
            lhs.yearEnd == rhs.yearEnd
    }
}
