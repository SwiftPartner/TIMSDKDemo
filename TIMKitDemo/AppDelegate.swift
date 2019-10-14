//
//  AppDelegate.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import RxSwift
import coswift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = TIMSdkConfig()
        config.sdkAppId = 1400255804
        config.disableLogPrint = !Environment.isDebug()
        config.connListener = self
        TIMManager.sharedInstance()?.initSdk(config)   
        return true
    }
    
    @objc func timer() {
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate: TIMConnListener {
    
    func onConnecting() {
        TIMManager.sharedInstance()?.connectStatus = .connecting
        Log.i("腾讯IM: ", "连接中...")
    }
    
    func onConnSucc() {
        TIMManager.sharedInstance()?.connectStatus = .success
        Log.i("腾讯IM: ", "连接成功...")
    }
    
    func onConnFailed(_ code: Int32, err: String!) {
        TIMManager.sharedInstance()?.connectStatus = .failed
        Log.w("腾讯IM: ", "连接失败,错误码\(code)，错误描述 -> \(err ?? "无")")
    }
    
    func onDisconnect(_ code: Int32, err: String!) {
        TIMManager.sharedInstance()?.connectStatus = .disconnect
        Log.w("腾讯IM: ", "断开链接，错误码\(code)，错误描述 -> \(err ?? "无")")
    }
}

public extension TIMManager {
    
    private struct TIMConnectStatusHolder {
        static var connectStatusObservable =  ReplaySubject<TIMConnectstatus>.create(bufferSize: 1)
        static var stutus:TIMConnectstatus = .connecting {
            didSet { connectStatusObservable.onNext(stutus) }
        }
    }
    
    var connectStatus: TIMConnectstatus {
        get { return TIMConnectStatusHolder.stutus }
        set { TIMConnectStatusHolder.stutus = newValue }
    }
    
    var connectStatusObservable:ReplaySubject<TIMConnectstatus> {
        return TIMConnectStatusHolder.connectStatusObservable
    }
}

public extension TIMManager {
}
