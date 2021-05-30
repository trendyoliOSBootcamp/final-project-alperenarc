//
//  HomeEndpointItem.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import CoreNetwork

enum EndpointItem: Endpoint {
    case games(page: String, platform: String?)
    case game(id: String)
    case searchGame(searchText: String, page: String, platform: String?)
    case categories

    var baseUrl: String { "https://api.rawg.io/api/" }
    var apiKey: String { Keys.ApiKey }
    var path: String {
        switch self {
        case .games(let page, let platform): return "games?key=\(apiKey)&page=\(page)\(platform ?? "")"
        case .game(let id): return "games/\(id)?key=\(apiKey)"
        case .searchGame(let searchText, let page, let platform): return "games?key=\(apiKey)&page=\(page)&search=\(searchText)\(platform ?? "")"
        case .categories: return "platforms/lists/parents?key=\(apiKey)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .games: return .get
        case .game: return .get
        case .searchGame: return .get
        case .categories: return .get
        }
    }
}
