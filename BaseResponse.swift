//
//  BaseResponse.swift
//  vanpool-passenger-ios
//

import ObjectMapper

class BaseResponse: Mappable {
  var status: Int?
  var message: Message?

  required init?(map: Map) {

  }

  // Mappable
  func mapping(map: Map) {
    status <- map["status"]
    message <- map["messages.0"]
  }
}
class Message: Mappable {
  var type: Int?
  var key: String?
  var text: String?
  var valueType: Int?

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    type <- map["messageType"]
    key <- map["messageKey"]
    text <- map["messageText"]
    valueType <- map["messageValueType"]
  }
}
