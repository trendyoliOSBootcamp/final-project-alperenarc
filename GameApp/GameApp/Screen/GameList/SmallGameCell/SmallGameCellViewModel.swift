//
//  SmallGameCellViewModel.swift
//  GameApp
//
//  Created by Alperen Arıcı on 28.05.2021.
//

import Foundation

// MARK: - SmallGameCellViewModelProtocol
protocol SmallGameCellViewModelProtocol {
    var delegate: SmallGameCellViewModelDelegate? { get set }
    var getWishListStatus: Bool { get }
    func load()
}

// MARK: - SmallGameCellViewModelDelegate
protocol SmallGameCellViewModelDelegate: AnyObject {
    func prepareWishListButton(wishListStatus: Bool)
    func prepareImage(image: String)
    func prepareName(name: String, isClicked: Bool)
    func changeNameColor()
}

// MARK: - SmallGameCellViewModel
final class SmallGameCellViewModel {
    weak var delegate: SmallGameCellViewModelDelegate?
    private let gameResult: GameResult?
    private var wishListStatus: Bool = false
    private var clickedStatus: Bool = false
    init(gameResult: GameResult?, wishListStatus: Bool, clickedStatus: Bool) {
        self.gameResult = gameResult
        self.wishListStatus = wishListStatus
        self.clickedStatus = clickedStatus
    }
}

// MARK: - SmallGameCellViewModelProtocol
extension SmallGameCellViewModel: SmallGameCellViewModelProtocol {
    var getWishListStatus: Bool { self.wishListStatus }
    func load() {
        guard let image = gameResult?.backgroundImage, let name = gameResult?.name else { return }
        delegate?.prepareName(name: name, isClicked: clickedStatus)
        delegate?.prepareImage(image: image)
        delegate?.prepareWishListButton(wishListStatus: wishListStatus)
    }
}
