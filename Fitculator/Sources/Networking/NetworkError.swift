//
//  NetworkError.swift
//  Fitculator
//
//  Created by 임재현 on 2/24/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidAPIKey(String?)
    case suspendedAPIKey(String?)
    case authenticationFailed(String?)
    case accessDenied(String?)
    case invalidURL(String?)
    
    case invalidParameters(String?)
    case invalidDateRange(start: String, end: String)
    case invalidPage(Int)
    case invalidDate(String)
    case tooManyRequests(limit: Int)
    case tooManyAppendResponses(Int)
    case invalidTimezone(String?)
    case confirmationRequired
    
    case invalidResponse
    case resourceNotFound(String?)
    case duplicateEntry(String?)
    case serviceOffline
    case maintenanceMode
    case timeout
    case invalidFormat(String?)
    case backendConnectionError(String?)
    
    case invalidToken(String?)
    case sessionNotFound
    case emailNotVerified
    case accountDisabled
    case userSuspended
    
    case decodingError(Error)
    case networkError(Error)
    case unknown(statusCode: Int, message: String?)
    
    var errorDescription: String? {
            switch self {
            case .invalidAPIKey(let message):
                return "Invalid API key. \(message ?? "Please check your API key.")"
            case .suspendedAPIKey(let message):
                return "Your API key has been suspended. \(message ?? "Please contact TMDB.")"
            case .authenticationFailed(let message):
                return "Authentication failed. \(message ?? "Please check your credentials.")"
            case .accessDenied(let message):
                return "Access denied. \(message ?? "You don't have permission to access this resource.")"
                           
            case .invalidParameters(let param):
                return "Invalid parameters provided: \(param ?? "unknown parameter")"
            case .invalidDateRange(let start, let end):
                return "Invalid date range: \(start) to \(end). Date range should not exceed 14 days."
            case .invalidPage(let page):
                return "Invalid page number: \(page). Pages should be between 1 and 500."
            case .invalidDate:
                return "Invalid date format. Use YYYY-MM-DD format."
            case .tooManyRequests(let limit):
                return "Rate limit exceeded. Maximum requests allowed: \(limit)"
            case .tooManyAppendResponses(let count):
                return "Too many append to response objects: \(count). Maximum is 20."
            case .invalidTimezone(let timezone):
                return "Invalid timezone provided: \(timezone ?? "unknown")"
            case .confirmationRequired:
                return "Action needs confirmation. Please provide confirm=true parameter."
                
            case .invalidResponse:
                return "Received invalid response from the server."
            case .resourceNotFound:
                return "The requested resource could not be found."
            case .duplicateEntry:
                return "The data you tried to submit already exists."
            case .serviceOffline:
                return "Service is temporarily offline. Please try again later."
            case .maintenanceMode:
                return "The API is currently under maintenance. Please try again later."
            case .timeout:
                return "Request timed out. Please try again."
            case .invalidFormat:
                return "The requested format is not supported."
            case .backendConnectionError:
                return "Could not connect to the backend server."
                
            case .invalidToken:
                return "The provided token is invalid or expired."
            case .sessionNotFound:
                return "The requested session could not be found."
            case .emailNotVerified:
                return "Please verify your email address."
            case .accountDisabled:
                return "Your account has been disabled. Please contact TMDB."
            case .userSuspended:
                return "This user account has been suspended."
                
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network error occurred: \(error.localizedDescription)"
            case .unknown(let statusCode, let message):
                return "Unknown error occurred (Status: \(statusCode)): \(message ?? "No additional information")"
            case .invalidURL(let url):
                return "Invalid URL: \(url ?? "unknown URL")"
            }
        }
    
    
    static func from(statusCode: Int, message: String?) -> NetworkError {
           switch statusCode {
           case 401:
               if message?.contains("API key") ?? false {
                   return .invalidAPIKey(message)
               } else if message?.contains("suspended") ?? false {
                   return .suspendedAPIKey(message)
               } else {
                   return .authenticationFailed(message)
               }
           case 404:
               return .resourceNotFound(message)
           case 422:
               if message?.contains("date range") ?? false {
                   return .invalidDateRange(start: "unknown", end: "unknown")
               } else {
                   return .invalidParameters(message)
               }
           case 429:
               return .tooManyRequests(limit: 40)
           case 503:
               if message?.contains("maintenance") ?? false {
                   return .maintenanceMode
               } else {
                   return .serviceOffline
               }
           case 504:
               return .timeout
           default:
               return .unknown(statusCode: statusCode, message: message)
           }
       }
}
