//
//  GameSearchResult.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//
import Foundation

// MARK: - Category
struct GameSearchResult: Codable {
    let count: Int?
    let next, previous: String?
    let results: [SearchResult]?
    let userPlatforms: Bool?
}

// MARK: - Result
struct SearchResult: Codable {
    let slug, name: String?
    let playtime: Int?
    let platforms: [SearchResultPlatform]?
    let stores: [SearchResultStore]?
    let released: String?
    let tba: Bool?
    let backgroundImage: String?
    let rating: Double?
    let ratingTop: Int?
    let ratings: [SearchResultRating]?
    let ratingsCount, reviewsTextCount, added: Int?
    let addedByStatus: SearchResultAddedByStatus?
    let metacritic: Int?
    let suggestionsCount: Int?
    let updated: String?
    let id: Int?
    let score: String?
    let tags: [Tag]?
    let esrbRating: SearchResultEsrbRating?
    let reviewsCount: Int?
    let shortScreenshots: [SearchResultShortScreenshot]?
    let parentPlatforms: [SearchResultPlatform]?
    let genres: [SearchResultGenre]?
    let communityRating: Int?
}

// MARK: - AddedByStatus
struct SearchResultAddedByStatus: Codable {
    let yet, owned, beaten, toplay: Int?
    let dropped, playing: Int?
}

// MARK: - EsrbRating
struct SearchResultEsrbRating: Codable {
    let id: Int?
    let name, slug, nameEn, nameRu: String?
}

// MARK: - Genre
struct SearchResultGenre: Codable {
    let id: Int?
    let name, slug: String?
}

// MARK: - Platform
struct SearchResultPlatform: Codable {
    let platform: Genre?
}

// MARK: - Rating
struct SearchResultRating: Codable {
    let id: Int?
    let title: String?
    let count: Int?
    let percent: Double?
}

// MARK: - ShortScreenshot
struct SearchResultShortScreenshot: Codable {
    let id: Int?
    let image: String?
}

// MARK: - Store
struct SearchResultStore: Codable {
    let store: SearchResultGenre?
}

// MARK: - Tag
struct Tag: Codable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?
}
