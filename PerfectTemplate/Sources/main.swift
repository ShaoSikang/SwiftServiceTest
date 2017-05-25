//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

var routes = Routes()

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(data: [String:Any]) throws -> RequestHandler {
	return {
		request, response in
		// Respond with a simple message.
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		// Ensure that response.completed() is called when your processing is done.
		response.completed()
	}
}

func testGetHandle(data : [String : Any]) throws -> RequestHandler {
    return { (HTTPRequest, HTTPResponse) in
        let keys = ["username", "password"]
        var values = checkParamExist(keys: keys, HTTPRequest: HTTPRequest, HTTPResponse: HTTPResponse)
        if values.isEmpty {
            return
        }
        if !checkParamLength(name: "username", key: values[0], lenght: 6, HTTPResponse: HTTPResponse) {
            return
        }
        if !checkParamLength(name: "password", key: values[1], lenght: 6, HTTPResponse: HTTPResponse) {
            return
        }
        do{
            try HTTPResponse.setBody(json: ["username":values[0], "password":values[1]])
            HTTPResponse.completed()
        }catch{
            print(error)
        }
    }
}

func createHandle(data : [String : Any]) throws -> RequestHandler {
    return { (HTTPRequest, HTTPResponse) in
//        HTTPRequest.setHeader(.contentType, value: "applicattion/json")
//        HTTPResponse.setHeader(.contentType, value: "application/json")
        let posts = HTTPRequest.postParams
        let postString = HTTPRequest.postBodyString!
//        let decode = postString.jsonDecode()
//        let de = try decode.jsonDecode() as ? [String : Any]
//        do {
//            let ss = "ddddd"
//            let paramJson = try ss.jsonDecode() as? [String: Any]
//            for (key, value) in paramJson! {
//                print("key : ", key)
//                print("value : ", value)
//            }
//        } catch {
//            print("post param json error")
//            return
//        }
        print("postString : ", postString)
        let keys = ["username", "password"]
        var values = checkParamExist(keys: keys, HTTPRequest: HTTPRequest, HTTPResponse: HTTPResponse)
        if values.isEmpty {
            return
        }
        if !checkParamLength(name: "username", key: values[0], lenght: 6, HTTPResponse: HTTPResponse) {
            return
        }
        if !checkParamLength(name: "password", key: values[1], lenght: 6, HTTPResponse: HTTPResponse) {
            return
        }
        guard let json = UserOperator().insertUserInfo(userName: values[0], password: values[1]) else {
            HTTPResponse.completed()
            return
        }
        HTTPResponse.setBody(string: json)
        HTTPResponse.completed()
    }
}

func checkParamExist(keys : [String], HTTPRequest : HTTPRequest, HTTPResponse: HTTPResponse) -> [String] {
    var results = [String]()
    for key in keys {
        guard let value = HTTPRequest.param(name: key) else {
            do{
                try HTTPResponse.setBody(json: ["error":"param error, \(key) is nil","code":300])
                HTTPResponse.completed()
            }catch{
                print(error)
            }
            return []
        }
        results.append(value)
    }
    return results
}

func checkParamLength(name : String, key : String, lenght : Int, HTTPResponse : HTTPResponse) -> Bool {
    if key.characters.count < lenght {
        do{
            try HTTPResponse.setBody(json: ["error":"param error, \(name) shorter than \(lenght)","code":301])
            HTTPResponse.completed()
        }catch{
            print(error)
        }
        return false
    }
    return true
}

// Configuration data for two example servers.
// This example configuration shows how to launch one or more servers 
// using a configuration dictionary.

let port1 = 8080, port2 = 8181

let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"localhost",
			"port":port1,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
				["method":"get", "uri":"/create", "handler":testGetHandle],
				["method":"post", "uri":"/create", "handler":createHandle],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		],
		// Configuration data for another server which:
		//	* Redirects all traffic back to the first server.
		[
			"name":"localhost",
			"port":port2,
			"routes":[
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
				 "base":"http://localhost:\(port1)"]
			]
		]
	]
]

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

