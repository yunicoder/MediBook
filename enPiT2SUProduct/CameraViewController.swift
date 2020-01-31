//
//  CameraViewController.swift
//  enPiT2SUProduct
//
//  Created by Takuma Yabe on 2019/11/23.
//  Copyright © 2019 Jun Ohkubo. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class CameraViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    var sendtext : String?
    var JANCODE: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCaptureSession()
        setupDevice()
        setupPreviewLayer()
        setupBarcodeCapture()
    }
    
    @IBAction  func myUnwindAction(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        captureSession.startRunning()
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

/*    private func convertISBN(value: String) -> String? {
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
 */
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else { return }
        for metadataObject in metadataObjects {
            guard cameraPreviewLayer!.transformedMetadataObject(for: metadataObject) is AVMetadataMachineReadableCodeObject,
                let object = metadataObject as? AVMetadataMachineReadableCodeObject,
                let jan = object.stringValue
                    //let isbn = convertISBN(value: value)
            else { continue }
            
            JANCODE = jan
            print("読み込んだ値:\t\(jan)\nJAN:\t\(jan)")
            captureSession.stopRunning()

            performSegue(withIdentifier: "ModalSegue", sender: nil)

            break
        }
    }
    
    override func prepare (for segue: UIStoryboardSegue,sender: Any!){
        if (segue.identifier == "ModalSegue") {
            let SVController = (segue.destination as? ModalViewController)!
            //SecondScreenで宣言した変数（String型）にsenderの値を格納する
            SVController.receiveText = JANCODE!
        }
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
