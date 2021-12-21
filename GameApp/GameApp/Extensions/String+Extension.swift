//
//  String+Extension.swift
//  GameApp
//
//  Created by Alperen Arıcı on 1.06.2021.
//

import Foundation

extension String {
    func dateFormatMMMdyy() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, yyyy"
        if let date = dateFormatterGet.date(from: self) {
            return dateFormatterPrint.string(from: date)
        }
        return "Wrong Format !"
    }
}
