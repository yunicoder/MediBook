//
//  Readcsv.swift
//  enPiT2SUProduct
//
//  Created by 松井大志 on 2019/11/08.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import Foundation

class ExpandCSV {
    var value = [[String]]() //csv格納
    
    init(filename: String){
        //CSVファイルパスを取得
        if let path = Bundle.main.path(forResource:filename, ofType:"csv") {
            //CSVデータ読み込み
            do {
                let csvString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                //CSVデータを1行ずつ読み込む
                let csvLines = csvString.components(separatedBy:CharacterSet.newlines)
                //カンマ区切りで分割
                for line in csvLines {
                    if line.contains(",") {
                        value.append(line.components(separatedBy: ","))
                    }
                }
                
            } catch let error {
                //ファイル読み込みエラー時
                print(error)
            }
        }else {
            print("not found csv file")
        }
    }
    
    
    //vlookupを行いindexで指定された列の文字列を返す
    func vlookup(key: String, index: Int) -> String?{
        for line in value {
            if line[0] == key {
                return line[index - 1]
            }
        }
        return nil
    }
    
    //複数のindexを指定できるvlookup
    func vlookup(key: String, indexs: Int...) -> [String]?{
        for line in value {
            if line[0] == key {
                var tmp = [String]()
                for i in indexs {
                    tmp.append(line[i-1])
                }
                return tmp
            }
        }
        return nil
    }
}
