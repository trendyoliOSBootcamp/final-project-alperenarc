//
//  ViewController.swift
//  GameApp
//
//  Created by Alperen Arıcı on 24.05.2021.
//

import UIKit
import CoreNetwork

class ViewController: UIViewController {
    let networkManager: NetworkManager<EndpointItem> = NetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.request(endpoint: .searchGame(searchText: "CSGO"), type: GameSearchResult.self) { result in
            switch result {
            case .success(let response):
                print(response)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}

