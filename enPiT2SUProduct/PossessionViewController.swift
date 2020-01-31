//
//  PossessionViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit
import SwiftyJSON


class PossessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Outlet接続
    @IBOutlet weak var possessionTableView: UITableView!
    
    // 変数宣言
    var mediInfo = [MediData]() // 薬のデータ
    var possessionMediInfo = [MediData]() // 所持中に登録されている薬の情報
    
    
    /* tabelViewの委譲　開始*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possessionMediInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データを表示するセルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        // セルごとに値を代入
        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView { // 薬の写真
            imageView.image = getImageByUrl(url: possessionMediInfo[indexPath.row].imgUrl)
        }
        if let nameLabel = cell.contentView.viewWithTag(2) as? UILabel { // 薬名
            nameLabel.text =  possessionMediInfo[indexPath.row].name 
        }
        if let isFavButton = cell.contentView.viewWithTag(3) as? UIButton { // お気に入りかどうか
           if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
                let isfavImage = possessionMediInfo[indexPath.row].isFav ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                isFavButton.setImage(isfavImage, for: .normal) // お気に入りの時はfill、そうでない時はstarを表示
            } else { // 前のバージョンの時はとりあえずテキストを入れとく
                // Fallback on earlier versions
            isFavButton.titleLabel?.text = possessionMediInfo[indexPath.row].isFav ? "お気に入り設定中" : "お気に入り解除中"
            }
        }
        if let genreLabel = cell.contentView.viewWithTag(4) as? UILabel { // 症状
            genreLabel.text = possessionMediInfo[indexPath.row].genre
        }
        if let memoLabel = cell.contentView.viewWithTag(5) as? UILabel { // メモ
            memoLabel.text = possessionMediInfo[indexPath.row].memo
        }
        if let remindLabel = cell.contentView.viewWithTag(6) as? UILabel { // リマインド
            var text = ""
            var flag = false
            if(possessionMediInfo[indexPath.row].isRemind[0] == true) {
                text += "朝"
                flag = true
            }else{
                text += "    "
            }
            text += "        "
            if(possessionMediInfo[indexPath.row].isRemind[1] == true) {
                text += "昼"
                flag = true
            }else{
                text += "    "
            }
            text += "        "
            if(possessionMediInfo[indexPath.row].isRemind[2] == true) {
                text += "夜"
                flag = true
            }else{
                text += "    "
            }
            
            if(flag == false){
                text = "なし"
            }
            remindLabel.text = text
        }
        
        
        // データを設定したセルを返却する
        return cell
    }
     /* tabelViewの委譲　終了*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediInfo = loadMediInfo()
        possessionMediInfo = mediInfo.filter({ $0.isPossession == true})
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // データの再読み込み
        mediInfo = loadMediInfo()
        possessionMediInfo = mediInfo.filter({ $0.isPossession == true})
        possessionTableView.reloadData() // コレクションビューのリロード
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // セグエによる画面遷移が行われる前に呼ばれるメソッド
        if (segue.identifier == "toEdit") {
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = possessionTableView.indexPathsForSelectedRows! // 選ばれた
            editVC.sendedData = possessionMediInfo[selectedRow[0].row]
        }
    }

}
