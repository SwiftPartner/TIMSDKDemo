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
import IQKeyboardManagerSwift
import CommonTools

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
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
    
    func createGroup(groupInfo: TIMCreateGroupInfo) -> Promise<TICResult>{
        let promise = Promise<TICResult>()
        TIMGroupManager.sharedInstance()?.createGroup(groupInfo, succ: { group in
            promise.fulfill(value: TICResult(code: 0, desc: "群组创建成功"))
        }, fail: { (code, desc) in
            if code == 10025 {
                promise.fulfill(value: TICResult(code: 0, desc: "群组已存在，不需要再次创建"))
            } else {
                promise.fulfill(value: TICResult(code: code, desc: desc))
            }
        })
        return promise
    }
    
    func joinGroup(groupId: String) -> Promise<TICResult> {
        let promise = Promise<TICResult>()
        TIMGroupManager.sharedInstance()?.joinGroup(groupId, msg: "", succ: {
            promise.fulfill(value: TICResult(code: 0, desc: "已加入群组"))
        }, fail: { (code, desc) in
            if code == 10013 {
                promise.fulfill(value: TICResult(code: 0, desc: "已经在群组了，不需要再次申请"))
            } else {
                promise.fulfill(value: TICResult(code: code, desc: desc))
            }
        })
        return promise
    }
    
    func createAndJoinGroup(_ groupInfo: TIMCreateGroupInfo) -> Promise<TICResult> {
        return createGroup(groupInfo: groupInfo).then { result -> Promise<TICResult> in
            if result.isSuccess {
                return self.joinGroup(groupId: groupInfo.group!)
            }
            let promise = Promise<TICResult>()
            promise.fulfill(value: result)
            return promise
        }
    }
}

extension TIMConversation {
    func sendMessage(_ message: TIMMessage) -> Promise<TICResult> {
        let promise = Promise<TICResult>()
        send(message, succ: {
            promise.fulfill(value: TICResult(code: 0, desc: "消息发送成功"))
        }) { (code, desc) in
            promise.fulfill(value: TICResult(code: code, desc: desc))
        }
        return promise
    }
}
