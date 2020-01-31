//
//  DataMgr.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/12/16.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

// データをまとめたファイル

import Foundation
import UIKit
import SwiftyJSON



/*---
 型と変数達　開始
 ---*/

let keyForMediInfo = "mediInfoKey" // 保存された薬情報を取ってくる時のUserDefaltsのKey
let keyForHistory = "historyKey" // 閲覧履歴を管理するためのUserDefaltsのKey


// 薬のデータ
struct MediData : Codable{
    var itemcode: String // アイテムコード
    var name: String // 名前
    var imgUrl: String // 大きい画像のURL
    var memo: String // メモ
    var isPossession: Bool // 所持中かどうか
    var isFav: Bool // お気に入りかどうか
    var genre: String //ジャンル
    var isRemind: [Bool] //リマインドするかどうか
}
// イニシャライザ
extension MediData{
    init(){
        itemcode = "アイテムコードなし"
        name = "名前なし"
        imgUrl = "URLなし"
        memo = "メモなし"
        isPossession = false
        isFav = false
        genre = "分類なし"
        isRemind = [false, false, false]
    }
}

// 症状
enum Condition : Int{
    case NULL = -1 // null
    case COLD = 0 // 風邪
    case HEADACHE = 1 // 頭痛
    case STOMACH = 2 // 腹痛
    case RHINITIS = 3 // 鼻炎
}

/*---
 型と変数達　終了
 ---*/


/*---
 データを扱う関数達　開始
 ---*/

// 薬情報を保存する関数(引数は保存する全データ)
func saveMediInfoMulti(_ mediInfos: [MediData]) {
    let data = mediInfos.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(data, forKey: keyForMediInfo)
}

// 薬情報を追加する関数(引数は追加する薬のデータ)
func addMediInfo(_ newMediInfo: MediData) {
    var allMediInfo = loadMediInfo()
    if let index = allMediInfo.firstIndex(where: { $0.itemcode == newMediInfo.itemcode}) {// 既にある場合は更新
        allMediInfo[index] = newMediInfo
    }
    else{ // 新規の場合は一番後ろに追加
        allMediInfo.append(newMediInfo)
    }
    
    let data = allMediInfo.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(data, forKey: keyForMediInfo)
}


//  薬情報を読み込む関数
func loadMediInfo() -> [MediData] {
    guard let encodedData = UserDefaults.standard.array(forKey: keyForMediInfo) as? [Data] else {
        return []
    }

    return encodedData.map { try! JSONDecoder().decode(MediData.self, from: $0) }
}

//  閲覧履歴を読み込む関数
func loadHistoryInfo() -> [MediData] {
    guard let encodedData = UserDefaults.standard.array(forKey: keyForHistory) as? [Data] else {
        return []
    }

    return encodedData.map { try! JSONDecoder().decode(MediData.self, from: $0) }
}

// 閲覧履歴に薬データを追加
func addHistoryInfo(_ newMediInfo: MediData) {
    var allHistoryMediInfo = loadHistoryInfo()
    if let index = allHistoryMediInfo.firstIndex(where: { $0.itemcode == newMediInfo.itemcode}) {// 閲覧履歴に既にある場合は昔のものを削除
        allHistoryMediInfo.remove(at: index)
    }
    if allHistoryMediInfo.count == 20{// 閲覧履歴が20を越える場合は一番古いデータを削除
        allHistoryMediInfo.removeFirst()
    }
    allHistoryMediInfo.append(newMediInfo)
    let data = allHistoryMediInfo.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(data, forKey: keyForHistory)
}

// 閲覧履歴の全データのクリア
func allDeleteHistoryInfo(){
    UserDefaults.standard.removeObject(forKey: keyForHistory)
}

/*---
 データを扱う関数達　終了
 ---*/


//--- json関連 ------------------------------------------
var otcList = ExpandCSV(filename: "./DataList/otc_list")

func createMadiDataFromJson(json: JSON) -> MediData?{
    let itemCode = json["Item"]["itemCode"].rawString()!
    let mediInfo = loadMediInfo()
    var newData: MediData? = nil
    
    //薬データがすでに保存されてればそれを呼び出す
    if let i = mediInfo.firstIndex(where: { $0.itemcode == itemCode}) {
        newData = mediInfo[i]
    }
    //なければ新しく作る
    else {
        if let otcName = otcList.vlookup(key: itemCode, index: 2){
            newData = MediData.init()
            newData!.itemcode = json["Item"]["itemCode"].rawString()!
            newData!.name = otcName
            newData!.imgUrl = json["Item"]["mediumImageUrls"][0]["imageUrl"].rawString()!
        }
    }
    
    return newData
}
//--- json関連終わり -------------------------------------------------------


/*-------
 (補足)データ関係使い方例

<データの読み込み(各ファイル必ず必要)>
 var mediInfo = [MediData]() // 薬のデータ <-ファイル内に必ず宣言しておく必要あり
 mediInfo = loadMediInfo() // データのロード
 
<データの保存>
 saveMediInfo(mediInfo) // データの保存

<新たなデータの追加>
 mediInfo.append(MediData(jancode: 20000, name: "ベンザブロック", url: "https://images-na.ssl-images-amazon.com/images/I/71WXdwERG8L._SX466_.jpg", hukusayou: "少し眠気がする可能性があります", condition: 1, memo: "僕のお気に入りです", isPossessin: false, isFav: true))
 
 <特定の値の読み出し>
 // 使用例1(名前がベンザブロックのもののみ取り出す)
print(mediInfo.filter({ $0.name == "ベンザブロック"})) // 名前がベンザブロックのものを全てを配列で返す(以下のような形)
/* [enPiT2SUProduct.MediData(jancode: 20000, name: "ベンザブロック", url: "https://images-na.ssl-images-amazon.com/images/I/71WXdwERG8L._SX466_.jpg", hukusayou: "少し眠気がする可能性があります", condition: 1, memo: "僕のお気に入りです", isPossessin: false, isFav: true)] */
 
 // 使用例2(お気に入りのみを取り出す)
 var favoriteMediInfo = [MediData]() // お気に入り薬のデータを入れるための配列
 favoriteMediInfo =  mediInfo.filter({ $0.isFav == true}) // お気に入りに登録してある薬のみ取り出す
 
 
--------*/
