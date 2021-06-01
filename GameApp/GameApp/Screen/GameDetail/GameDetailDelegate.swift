//
//  GameDetailDelegate.swift
//  GameApp
//
//  Created by Alperen Arıcı on 1.06.2021.
//

import Foundation

protocol GameDetailDelegate:AnyObject {
    func addOrRemoveWishListFromDetail(id: Int)
}
