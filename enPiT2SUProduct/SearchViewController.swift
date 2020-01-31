//
//  SearchViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController , UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //var data = Interaction()Med
    @IBOutlet weak var searchMedi: UISearchBar!
    var searchText = "薬"
    var genreId = "558736"
    
   
    @IBOutlet weak var CollectionView: UICollectionView!
    let conditions = ["風邪薬","痛み止め","胃腸薬","鼻炎薬","目薬","キズ薬","のどの薬","ひふの薬","酔い止め"]
    let searchConditions = ["558738","558741","553363","558750","553396","553384","553369","553360","558804"]
    
    private let conditionImages = ["風邪薬","痛み止め","胃腸薬","鼻炎薬","目薬","キズ薬","のどの薬","皮膚の薬","酔い止め"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //検索バーの設定
        
        searchMedi.delegate = self
        searchMedi.searchBarStyle = UISearchBar.Style.default
        searchMedi.showsSearchResultsButton = false
        
        view.backgroundColor = UIColor.groupTableViewBackground
        
        
        //view.backgroundColor = UIColor.init(red: 159/255, green: 255/255, blue: 251/255, alpha: 1)
        
        layoutInit(CollectionView: CollectionView) // コレクションビューのレイアウトの設定
        
    }
    
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text ?? ""
        searchBar.text = ""
        searchMedi.endEditing(true)
        self.performSegue(withIdentifier: "toSearchResult", sender: self)
    }
    
    //performSegue内部で呼ばれるメソッドのオーバーライド（次の画面への値渡し）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchResult" {
            let svc = segue.destination as! NameSearchViewController
            svc.searchText = searchText
            svc.genreId = genreId
            searchText = "薬"
            genreId = "558736"
        }
    }
    
    //-----------CollectionViewの設定---------------
    //セル数の設定
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conditions.count
    }
    //セルの設定
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 表示するセルを登録
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        //セルの背景色の設定
        //パターン1
        //cell.backgroundColor = UIColor.init(red: 90/255, green: 200/255, blue: 250/255, alpha: 1)
        //パターン2
        //cell.backgroundColor = UIColor.init(red: 255/255, green: 192/255, blue: 167/255, alpha: 1)
        
        //パターン３
        //cell.backgroundColor = UIColor.init(red:184/255, green:241/255, blue: 255/255, alpha: 100/100)
        
        //パターン4
       // cell.backgroundColor = .black
        
        //パターン5 アイコンの背景と同じ
            //cell.backgroundColor = UIColor.init(red:26/255, green:45/255, blue: 59/255, alpha: 100/100)
        
        //パターン6 アイコンの文字と同じ
       // cell.backgroundColor = UIColor.init(red:107/255, green:158/255, blue: 158/255, alpha: 100/100)
        
        //パターン7
            //cell.backgroundColor = UIColor.init(red:0/255, green:102/255, blue: 102/255, alpha: 100/100)
        
        cell.backgroundColor = UIColor.init(red:0/255, green:139/255, blue: 139/255, alpha: 100/100)
        //ツルハ
        //cell.backgroundColor = UIColor.init(red:255/255, green:195/255, blue:62/255, alpha: 1)
        
        //セルの角に丸みを帯びさせる
        cell.layer.cornerRadius = 20
        
        
        // Tag番号を使ってLabelのインスタンス生成
        //let label = cell.contentView.viewWithTag(2) as! UILabel
        //label.text = conditions[indexPath.row]
        
        let label = cell.viewWithTag(3) as! UILabel
        label.tag = indexPath.row //タグを設定
        label.text = conditions[indexPath.row]
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.makeOutLine(strokeWidth: -3.5, oulineColor: .darkText, foregroundColor: .white)
        label.adjustsFontSizeToFitWidth = true // 文字が見切れないようにフォントサイズを設定
        //UIColor.init(red:26/255, green:45/255, blue: 59/255, alpha: 1)
        //UIColor.init(red:94/255, green:215/255, blue: 211/255, alpha: 1)
        // Tag番号2番でセル内に画像を生成
               let photoImageView = cell.contentView.viewWithTag(2)  as! UIImageView
               let photoImage = UIImage(named: conditionImages[indexPath.row])
               photoImageView.image = photoImage
        
        // 画像を中央に設定
        photoImageView.center = CGPoint(x:cell.frame.size.width/2, y:cell.frame.size.height/2)

        // ---------セル内のボタンの設定-----------
        // セル内にたTag番号1番でボタンを生成
        let button = cell.viewWithTag(1) as! UIButton
        //ボタンを押した時の関数呼び出し
        button.addTarget(self, action: #selector(buttonPush(_:)), for: .touchUpInside)
        //それぞれのボタンのタグを設定
        button.tag = indexPath.row //タグを設定
        //button.setTitle(conditions[indexPath.row], for: .normal)
        
        
        
        //let conditionName = cell.viewWithTag(3) as! UILabel
        //conditionName.tag = indexPath.row
        //conditionName.text = conditions[indexPath.row]
        
        
        return cell
    }
    

    //-----------collectionViewのボタンが押された時のメソッド---------------
    @IBAction func buttonPush(_ sender: Any) {
        let indexPath = IndexPath(row: (sender as AnyObject).tag, section: 0)
        genreId = searchConditions[indexPath.row]
        searchMedi.endEditing(true)
        self.performSegue(withIdentifier: "toSearchResult", sender: self)
    }
    
    //セルのレイアウト
    let margin:CGFloat = 3.0 // 縦横のマージン
    let itemsPerRow:CGFloat = 3.0 // セルの列の数
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 対象のインデックス番号に対応するセルの大きさを返す
        //let width = collectionView.bounds.size.width / columnNum -  margin*3
        let widthPerItem = self.view.bounds.width / 3 - self.view.bounds.width/10
        // 横はcolumnNum(:4)列
        return CGSize(width: widthPerItem, height: widthPerItem)
        // 縦横情報をまとめる
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { // 横のマージン値を返す
//        return margin
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { // 縦のマージン値を返す
//        return margin
//    }
    
    func layoutInit(CollectionView: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 2, left: 25, bottom: 2, right: 25)
        CollectionView.collectionViewLayout = layout
    }
    // キャンセルボタンが押されたらキャンセルボタンを無効にしてフォーカスをはずす
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           //searchMedi.showsCancelButton = false
           searchMedi.resignFirstResponder()
       }
}
