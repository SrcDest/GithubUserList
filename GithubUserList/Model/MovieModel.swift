//
//  MovieModel.swift
//  GithubUserList
//
//  Created by shhan2 on 15/04/2019.
//  Copyright © 2019 test. All rights reserved.
//

import ObjectMapper

class MovieModel: Mappable {
    public var id: Int?
    public var title: String?
    public var year: Int?
    public var rating: Float?
    public var runtime: Int?
    public var genres: [String] = []
    public var description_full: String?
    public var language: String?
    public var small_cover_image: String?
    public var medium_cover_image: String?
    public var medium_screenshot_image1: String?
    public var medium_screenshot_image2: String?
    public var medium_screenshot_image3: String?
    public var cast: [CastModel] = []
    
    public init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        year <- map["year"]
        rating <- map["rating"]
        runtime <- map["runtime"]
        genres <- map["genres"]
        description_full <- map["description_full"]
        language <- map["language"]
        small_cover_image <- map["small_cover_image"]
        medium_cover_image <- map["medium_cover_image"]
        medium_screenshot_image1 <- map["medium_screenshot_image1"]
        medium_screenshot_image2 <- map["medium_screenshot_image2"]
        medium_screenshot_image3 <- map["medium_screenshot_image3"]
        cast <- map["cast"]
    }
    
    public class CastModel: Mappable {
        public var name: String?
        public var character_name: String?
        public var url_small_image: String?
        
        public init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        public func mapping(map: Map) {
            name <- map["name"]
            character_name <- map["character_name"]
            url_small_image <- map["url_small_image"]
        }
    }
}
