
//
//  OSSManager.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift

//public struct Secrets {
//    public static let aliyunSecrets = (keyID: "<#AccessKeyId#>", keySecrect: "<#AccessKeySecrect#>", endpoint: "<#endpoint#>", bucketName: "<#bucketName#>")
//}

public class OSSManager {
    public static let shared = OSSManager()
    public lazy var client: OSSClient = {
        let endpoint = Secrets.aliyunSecrets.endpoint
        let credentialProvider =  OSSAuthCredentialProvider { () -> OSSFederationToken? in
            let token = OSSFederationToken()
            token.tAccessKey = Secrets.aliyunSecrets.keyID
            token.tSecretKey = Secrets.aliyunSecrets.keySecrect
            return token
        }
        let config = OSSClientConfiguration()
        let ossClient = OSSClient(endpoint: endpoint, credentialProvider: credentialProvider, clientConfiguration: config)
        return ossClient
    }()
    
    private init() {}
    
    public func fetchBucket(name buckerName: String) -> Promise<OSSGetBucketResult> {
        let promise = Promise<OSSGetBucketResult>()
        let bucketRequest = OSSGetBucketRequest()
        bucketRequest.bucketName = buckerName
        let task = client.getBucket(bucketRequest)
        task.continue({ task -> Any? in
            if let result = task.result as? OSSGetBucketResult {
                promise.fulfill(value: result)
                return nil
            }
            promise.reject(error: task.error ?? OSSError.unknow)
            return nil
        }, cancellationToken: nil)
        task.waitUntilFinished()
        return promise
    }

    
    public func buildGetObjectReqeust(withBucketName name: String, objectKey: String) -> OSSGetObjectRequest {
        let request = OSSGetObjectRequest()
        request.objectKey = objectKey
        request.bucketName = name
        return request
    }
    
    public func download() {
        
    }
}
