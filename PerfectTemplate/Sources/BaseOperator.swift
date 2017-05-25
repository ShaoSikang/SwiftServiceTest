//
//  BaseOperator.swift
//  PerfectTemplate
//
//  Created by Sikang Shao on 2017/5/5.
//
//

import Cocoa
import MySQL

let RequestResultSuccess = "SUCCESS"
let RequestResultFail = "FAIL"
let ResultListKey = "list"
let ResultKey = "result"
let ErrorMessageKey = "errorMessage"
var BaseResponseJson : [String : Any] = [ResultListKey : [],
                                         ResultKey : RequestResultSuccess,
                                         ErrorMessageKey : ""]

class BaseOperator: NSObject {
    
    var mysql = MySQLConnect.shareInstance()
    
    var responseJson : [String : Any] = BaseResponseJson
    
}
