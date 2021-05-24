//
//  HomeEndpointItem.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import CoreNetwork

enum EndpointItem: Endpoint {
    case games
    case game(id: String)
    case searchGame(searchText: String)
    case categories

    var baseUrl: String { "https://api.rawg.io/api/" }
    var apiKey: String { Keys.ApiKey }
    var path: String {
        switch self {
        case .games: return "games?key=\(apiKey)"
        case .game(let id): return "games/\(id)?key=\(apiKey)"
        case .searchGame(let searchText): return "games?key=\(apiKey)&search=\(searchText)"
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
