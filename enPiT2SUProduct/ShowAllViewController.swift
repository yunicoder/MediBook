//
//  ShowAllViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit

class ShowAllViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    // Outlet接続
    @IBOutlet weak var TitleLabel: UILabel! //タイトル
    @IBOutlet weak var collectionView: UICollectionView! // 綺麗に並べるためのコレクションビュー
    @IBOutlet weak var titleIconImage: UIImageView! // タイトルの横に表示されるアイコン
    
    
    // マイページから受け取るデータ
    var titleText: String? // MypageViewControllerでタップされたタイトル
    var titleIconName: String? //MypageViewControllerでタップされたタイトルのアイコンの名前
    var showAllMediInfo = [MediData]() // 一覧表示する薬の情報
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self    // サイズやマージンなどレイアウトに関する処理の委譲
        collectionView.dataSource = self  // 要素の数やセル、クラスなどデータの元となる処理の委譲
        
        TitleLabel.text = titleText // 押されたタイトル
        
        // 押されたアイコンを代入
        if #available(iOS 13.0, *) { // ios13以降じゃないとデフォルトのアイコン使えないらしい
            titleIconImage.image = UIImage(systemName: titleIconName!)
        } else { // 前のバージョンの時はこ以下にかく
            // Fallback on earlier versions
        }
        
        // レイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
    }
    
    
    // URLから画像を生成する関数
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
    
    /*---collectionViewの委譲設定 開始---*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showAllMediInfo.count // 表示するセルの数
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) // 表示するセルを登録(先にStoryboad内でidentifierを指定しておく)
        
        if let collectionImage = cell.contentView.viewWithTag(1) as? UIImageView {
            // cellの中にあるcollectionImageに画像を代入する
            collectionImage.image = getImageByUrl(url: showAllMediInfo[indexPath.row].imgUrl)
        }
        if let collectionLabel = cell.contentView.viewWithTag(2) as? UILabel {
            // cellの中にあるcollectionImageに画像を代入する
            collectionLabel.text = showAllMediInfo[indexPath.row].name
            collectionLabel.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        }
        
        //cell.backgroundColor = .red  // セルの色をなんとなく赤に
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // 全体レイアウトの設定
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
    /*---collectionViewの設定の委譲など 終わり---*/
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // セグエによる画面遷移が行われる前に呼ばれるメソッド
        if (segue.identifier == "toEditFromFav") { // お気に入りカラムにて「写真」が押された時
            let editVC: EditViewController = (segue.destination as? EditViewController)!
            let selectedRow = collectionView.indexPathsForSelectedItems! // 選ばれた
            editVC.sendedData = showAllMediInfo[selectedRow[0].row]
        }
    }

}
