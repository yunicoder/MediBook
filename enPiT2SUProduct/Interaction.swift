//
//  Interaction.swift
//  enPiT2SUProduct
//
//  Created by 松井大志 on 2019/11/15.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import Foundation


var list = ExpandCSV(filename: "./DataList/interaction")
    
//２つの医薬品コードをもとに検索
func searchInteraction(_ mediNumber1: String, _ mediNumber2: String) -> String{
    var interaction = "危険情報なし"
    for line in list.value {
        if (mediNumber1.contains(line[0]) && mediNumber2.contains(line[1])) || (mediNumber1.contains(line[1]) && mediNumber2.contains(line[0])) {
            if(line[2] == "併用注意"){
                interaction = "併用注意"
            }
            else if(line[2] == "併用禁忌"){
                interaction = "併用禁忌"
            }
        }
    }
    return interaction
}
