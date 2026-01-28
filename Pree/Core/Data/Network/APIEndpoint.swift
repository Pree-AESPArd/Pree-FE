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
    case getTakes(projectId: String)
    case getResult(takeId: String)
    case fetchLatestAverageScores(userId: String)
    case searchProjects(userId: String, query: String)
    case deleteProject(projectId: String)
    
    
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
        case .getTakes(let projectId):
            return "/projects/\(projectId)/takes"
        case .getResult(let takeId):
            return "/takes/\(takeId)/result"
        case .fetchLatestAverageScores:
            return "/projects/latest/average-scores"
        case .searchProjects:
            return "/projects/search"
        case .deleteProject(let projectId):
            return "/projects/\(projectId)"
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
        case .getTakes:
            return .get
        case .getResult:
            return .get
        case .fetchLatestAverageScores:
            return .get
        case .searchProjects:
            return .get
        case .deleteProject:
            return .delete
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchProjects(let userId, let sortOption):
            return [
                "user_id": userId,
                "sort_option": sortOption
            ]
        case .fetchLatestAverageScores(let userId):
            return ["user_id": userId]
        case .searchProjects(let userId, let query):
            return [
                "user_id": userId,
                "query": query
            ]
        default:
            return nil
        }
    }
    
    var url: String {
        return "\(Config.baseURL)\(self.path)"
    }
}
