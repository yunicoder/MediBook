//
//  SupportAPI.swift
//  enPiT2SUProduct
//
//  Created by 松井大志 on 2019/12/13.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import Foundation
import UIKit

//URLから画像取得する関数
func getImageByUrl(url: String) -> UIImage{
    let url = URL(string: url)
    do {
        let data = try Data(contentsOf: url!)
        return UIImage(data: data)!
    } catch let err {
        print("Error : \(err.localizedDescription)")
    }
    return UIImage()
}

//文字列をURLエンコーディングする関数
func urlEncoded(str: String) -> String {
    // 半角英数字 + "/?-._~" のキャラクタセットを定義
    let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
    // 一度すべてのパーセントエンコードを除去(URLデコード)
    let removed = str.removingPercentEncoding ?? str
    // あらためてパーセントエンコードして返す
    return removed.addingPercentEncoding(withAllowedCharacters: charset) ?? removed
}


extension String {

    /// 正規表現でキャプチャした文字列を抽出する
    ///
    /// - Parameters:
    ///   - pattern: 正規表現
    ///   - group: 抽出するグループ番号(>=1)
    /// - Returns: 抽出した文字列
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }

    /// 正規表現でキャプチャした文字列を抽出する
    ///
    /// - Parameters:
    ///   - pattern: 正規表現
    ///   - group: 抽出するグループ番号(>=1)の配列
    /// - Returns: 抽出した文字列の配列
    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }

        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}



extension UILabel{

    /// makeOutLine
    ///
    /// - Parameters:
    ///   - strokeWidth: 線の太さ。負数
    ///   - oulineColor: 線の色
    ///   - foregroundColor: 縁取りの中の色
    func makeOutLine(strokeWidth: CGFloat, oulineColor: UIColor, foregroundColor: UIColor) {
        let strokeTextAttributes = [
            .strokeColor : oulineColor,
            .foregroundColor : foregroundColor,
            .strokeWidth : strokeWidth,
            .font : self.font
        ] as [NSAttributedString.Key : Any]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
    }
}
