//
//  CheckUpdateVersion.swift
//  HappyAnding
//
//  Created by 전지민 on 2022/11/29.
//

import UIKit
import Combine
import FirebaseFirestore

struct Version: Codable {
    var latestVersion: String
    var minimumVersion: String
    var description: String
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case latestVersion = "latest_version"
        case minimumVersion = "minimum_version"
        case title, description
    }
}

class CheckUpdateVersion {
    
    static let share = CheckUpdateVersion()
    private let db = Firestore.firestore()
    
    func fetchVersion(completionHandler: @escaping (Version, Bool)->()) {
        
        db.collection("Version")
            .getDocuments { (querySnapshot, error) in
                if let error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let decoder = JSONDecoder()
                
                for document in documents {
                    do {
                        let data = document.data()
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let version = try decoder.decode(Version.self, from: jsonData)
                        
                        let localVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                        
                        let isNeeded = self.checkIsNeededForceUpdate(localVersion: localVersionString, minimumVersion: version.minimumVersion)
                        print("**\(isNeeded)")
                        completionHandler(version, isNeeded)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
    
    func checkIsNeededForceUpdate(localVersion: String, minimumVersion: String) -> Bool {
        
        if (self.compareVersion(versionA: localVersion, versionB: minimumVersion) == ComparisonResult.orderedAscending) {
            return true
        } else {
            return false
        }
    }
    
    private func compareVersion(versionA:String!, versionB:String!) -> ComparisonResult {
        let majorA = Int(Array(versionA.split(separator: "."))[0])!
        let majorB = Int(Array(versionB.split(separator: "."))[0])!
        
        if majorA > majorB {
            return ComparisonResult.orderedDescending
        } else if majorB > majorA {
            return ComparisonResult.orderedAscending
        }
        
        let minorA = Int(Array(versionA.split(separator: "."))[1])!
        let minorB = Int(Array(versionB.split(separator: "."))[1])!
        if minorA > minorB {
            return ComparisonResult.orderedDescending
        } else if minorB > minorA {
            return ComparisonResult.orderedAscending
        }
        return ComparisonResult.orderedSame
    }
}
