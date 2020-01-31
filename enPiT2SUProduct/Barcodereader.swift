//
//  Barcodereader.swift
//  enPiT2SUProduct
//
//  Created by 片岡秀斗 on 2019/11/22.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//
import UIKit
import AVFoundation
import SwiftyJSON

class Barcodereader: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCaptureSession()
        setupDevice()
        setupPreviewLayer()
        setupBarcodeCapture()
    }

    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()

    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?

    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?

    // 入出力データの設定
    private var captureInput: AVCaptureInput? = nil
    
    private func setupBarcodeCapture() {
        do {
            captureInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSession.addInput(captureInput!)
            captureSession.addOutput(captureOutput)
            captureOutput.metadataObjectTypes = captureOutput.availableMetadataObjectTypes
            captureSession.startRunning()
        } catch let error as NSError {
            print(error)
        }
    }

    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?

    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
        
    private lazy var captureOutput: AVCaptureMetadataOutput = {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue:DispatchQueue.main)
        return output
    }()

    private func convertISBN(value: String) -> String? {
        let v = NSString(string: value).longLongValue
        let prefix: Int64 = Int64(v / 10000000000)
        guard prefix == 978 || prefix == 979 else { return nil }
        let isbn9: Int64 = (v % 10000000000) / 10
        var sum: Int64 = 0
        var tmpISBN = isbn9
        /*
        for var i = 10; i > 0 && tmpISBN > 0; i -= 1 {
            let divisor: Int64 = Int64(pow(10, Double(i - 2)))
            sum += (tmpISBN / divisor) * Int64(i)
            tmpISBN %= divisor
        }
        */

        var i = 10
        while i > 0 && tmpISBN > 0 {
            let divisor: Int64 = Int64(pow(10, Double(i - 2)))
            sum += (tmpISBN / divisor) * Int64(i)
            tmpISBN %= divisor
            i -= 1
        }

        let checkdigit = 11 - (sum % 11)
        return String(format: "%lld%@", isbn9, (checkdigit == 10) ? "X" : String(format: "%lld", checkdigit % 11))
    }
    
}

extension Barcodereader: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else { return }
        for metadataObject in metadataObjects {
            guard cameraPreviewLayer!.transformedMetadataObject(for: metadataObject) is AVMetadataMachineReadableCodeObject,
                let object = metadataObject as? AVMetadataMachineReadableCodeObject,
                let value = object.stringValue
                //let isbn = convertISBN(value: value)
            else { continue }

            print("読み込んだ値:\t\(value)\nJAN:\t\(value)")
            captureSession.stopRunning()

            let jan: String = value

            let url = URL(string: "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706?format=json&keyword="+jan+"&applicationId=1090319832973970265")
            
/*            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let data = data else {return}
                do {
                    let json = try? JSON(data: data)
                    let jsonData = json!["Items"][0]["Item"]["itemName"]
                    print(jsonData)
                }
                }.resume()
*/
//            UIApplication.shared.open(URL(string: "http://amazon.co.jp/dp/\(isbn)")!, options: [:], completionHandler: nil)
            break
        }
    }
}
