//
//  APIEndpoint.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import Foundation
import Alamofire

enum APIEndpoint {
    case fetchProjects(userId: String, sortOption: String)
    case createProject
    case uploadTake(projectId: String)
    case toggleFavorite(projectId: String)
    case getFiveTakesScores(projectId: String)
    
    
    var path: String {
        switch self {
        case .fetchProjects:
            return "/projects/"
        case .createProject:
            return "/projects/"
        case .uploadTake(let projectId):
            return "/projects/\(projectId)/takes"
        case .toggleFavorite(projectId: let projectId):
            return "/projects/\(projectId)/favorite"
        case .getFiveTakesScores(let projectId):
            return "/projects/\(projectId)/takes/recent-scores"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchProjects:
            return .get
        case .createProject:
            return .post
        case .uploadTake:
            return .post
        case .toggleFavorite:
            return .patch
        case .getFiveTakesScores:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchProjects(let userId, let sortOption):
            return [
                "user_id": userId,
                "sort_option": sortOption
            ]
        default:
            return nil
        }
    }
    
    var url: String {
        return "\(Config.baseURL)\(self.path)"
    }
}
