//
//  Game.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//
import Foundation

// MARK: - Game
struct Game: Codable {
    let id: Int?
    let slug, name, nameOriginal, gameDescription: String?
    let metacritic: Int?
    let metacriticPlatforms: [MetacriticPlatform]?
    let released: String?
    let tba: Bool?
    let updated: String?
    let backgroundImage, backgroundImageAdditional: String?
    let website: String?
    let rating: Double?
    let ratingTop: Int?
    let ratings: [Rating]?
    let reactions: [String: Int]?
    let added: Int?
    let addedByStatus: AddedByStatus?
    let playtime, screenshotsCount, moviesCount, creatorsCount: Int?
    let achievementsCount, parentAchievementsCount: Int?
    let redditURL: String?
    let redditName, redditDescription, redditLogo: String?
    let redditCount, twitchCount, youtubeCount, reviewsTextCount: Int?
    let ratingsCount, suggestionsCount: Int?
    let alternativeNames: [String]?
    let metacriticURL: String?
    let parentsCount, additionsCount, gameSeriesCount: Int?
    let reviewsCount: Int?
    let saturatedColor, dominantColor: String?
    let parentPlatforms: [ParentPlatform]?
    let platforms: [PlatformElement]?
    let stores: [Store]?
    let developers, genres, tags, publishers: [Developer]?
    let esrbRating: EsrbRating?
    let descriptionRaw: String?
}

// MARK: - AddedByStatus
struct AddedByStatus: Codable {
    let yet, owned, beaten, toplay: Int?
    let dropped, playing: Int?
}

// MARK: - Developer
struct Developer: Codable {
    let id: Int?
    let name, slug: String?
    let gamesCount: Int?
    let imageBackground: String?
    let domain, language: String?
}

// MARK: - EsrbRating
struct EsrbRating: Codable {
    let id: Int?
    let name, slug: String?
}

// MARK: - MetacriticPlatform
struct MetacriticPlatform: Codable {
    let metascore: Int?
    let url: String?
    let platform: MetacriticPlatformPlatform?
}

// MARK: - MetacriticPlatformPlatform
struct MetacriticPlatformPlatform: Codable {
    let platform: Int?
    let name, slug: String?
}

// MARK: - ParentPlatform
struct ParentPlatform: Codable {
    let platform: EsrbRating?
}
