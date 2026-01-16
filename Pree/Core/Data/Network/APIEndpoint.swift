//
//  APIEndpoint.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import Foundation
import Alamofire

enum APIEndpoint {
    case fetchProjects(userId: String)
    case createProject
    case uploadTake(projectId: String)
    
    var path: String {
        switch self {
        case .fetchProjects:
            return "/projects/"
        case .createProject:
            return "/projects/"
        case .uploadTake(let projectId):
            return "/projects/\(projectId)/takes"
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
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchProjects(let userId):
            return ["user_id": userId]
        default:
            return nil
        }
    }
    
    var url: String {
        return "\(Config.baseURL)\(self.path)"
    }
}
