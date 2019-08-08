//
//  IIHTTPImageRequest.swift
//  IIAlaSDK
//  图片上传类
//  Created by Noah_Shan on 2018/5/31.
//  Copyright © 2018年 Inspur. All rights reserved.
//

import Foundation

/*
 关于form-data body体的说明：
 
 //Content-Disposition: form-data; name="file"; filename="temp.png"
 
 https://blog.csdn.net/zllww123/article/details/77587292
 
 */

open class IIHTTPImageRequest: NSObject {
    
    /// 上传文件
    ///
    /// - Parameters:
    ///   - url: URL
    ///   - data: 数据数组
    ///   - fileName: 名称数组
    ///   - withName: bodypart头名称数组
    ///   - successAction: 成功action
    ///   - failAction: 失败action
    open class func uploadFile(url: String,
                               data: [Data],
                               fileName: [String],
                               withName: [String],
                               successAction: @escaping (_ result: ResponseClass) -> Void,
                               failAction: @escaping () -> Void) {
        
        let httpHeader = IIHTTPHeaderAndParams.analyzeHTTPHeader(nil)
        upload(multipartFormData: { (multipartFormData) in
            for i in 0 ..< data.count {
                let data = data[i]
                let fileName = fileName[i]
                let withName = withName[i]
                multipartFormData.append(data, withName: withName, fileName: fileName, mimeType: "")
            }
        }, to: url, headers: httpHeader) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let resultResponse = IHTTPProgressAFNCode.progressResponse(response: response)
                    if resultResponse.errorValue == nil {
                        successAction(resultResponse)
                    } else {
                        failAction()
                    }
                }
            case .failure:
                failAction()
            }
        }
        
    }
    
    /// 文件下载
    ///
    /// - Parameters:
    ///   - fileFolder: 是否放到自定义的目录中-可以放到默认文件夹中默认在~/documtent/下
    ///   - fileExtension: 文件保存的后缀，默认为txt
    ///   - url: url下载地址
    ///   - downLoadFilePath: 成功回调
    ///   - error: 失败回调
    @discardableResult
    open class func downLoadFile(fileName: String, fileFolder: String = "", fileExtension: String = "txt", url: String, downLoadFilePath: @escaping(_ path: Data?, _ filePath: URL?, _ mimeType: String) -> Void, error: @escaping () -> Void, downLoadProgress: ((_ progress: Double) -> Void)? = nil) -> DownloadRequest {
        //文件夹路径，如果是空则为默认目录，否则需要带着/
        let folder = fileFolder == "" ? "" : "\(fileFolder)/"
        //文件后缀-如果传空，则表明在文件名称中已经带入
        let extensionStr = fileExtension == "" ? "" : ".\(fileExtension)"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(folder)\(fileName)\(extensionStr)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let httpHeader = IIHTTPHeaderAndParams.analyzeHTTPHeader(nil)
        let downloadRequest = download(url,
                                       headers: httpHeader,
                                       to: destination)
            .downloadProgress(closure: { (progress) in
                downLoadProgress?(progress.fractionCompleted)
            })
            .responseData { (data) in
                if data.result.error == nil && data.response?.statusCode == 200 {
                    downLoadFilePath(data.result.value, data.destinationURL, data.response?.mimeType ?? "")
                } else {
                    error()
                }
        }
        return downloadRequest
    }
}
