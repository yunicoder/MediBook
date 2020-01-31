//
//  MyCombinatonSearchViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit

class MyCombinatonSearchViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var mediInfo = [MediData]() // 薬のデータ <-ファイル内に必ず宣言しておく必要あり
    var interactions = Dictionary<String, String>()//併用情報
    var selectedMediCode = String()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // セルに表示する値を設定する
        cell.textLabel!.text = mediInfo[indexPath.row].name
        cell.textLabel!.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        cell.imageView!.image = getImageByUrl(url: mediInfo[indexPath.row].imgUrl)
        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView { // 薬の写真
            if #available(iOS 13.0, *) {
                if (interactions[mediInfo[indexPath.row].itemcode] == "併用注意"){
                    imageView.image = UIImage(systemName: "triangle")
                    imageView.tintColor = UIColor.systemYellow
                }
                else if (interactions[mediInfo[indexPath.row].itemcode] == "併用禁忌"){
                    imageView.image = UIImage(systemName: "xmark")
                    imageView.tintColor = UIColor.red
                }
            }
        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // データのロード
        mediInfo = loadMediInfo().filter({ $0.isPossession == true}).filter({$0.itemcode != selectedMediCode})
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
