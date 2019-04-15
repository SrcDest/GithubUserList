//
//  MovieListModel.swift
//  GithubUserList
//
//  Created by shhan2 on 28/02/2019.
//  Copyright © 2019 test. All rights reserved.
//

import ObjectMapper

class MovieListModel: Mappable {
    public var movie_count: Int?
    public var movies: [MovieModel] = []
    
    public init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        movie_count <- map["movie_count"]
        movies <- map["movies"]
    }    
}
