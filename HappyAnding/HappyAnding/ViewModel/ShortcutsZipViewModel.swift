//
//  ShortcutsZipViewModel.swift
//  HappyAnding
//
//  Created by KiWoong Hong on 2022/11/01.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

/*
    shortcutsZip 앱 내에서 각 뷰에 필요한 데이터를 전달하기위한 ViewModel Class 입니다.
    * 해당 class 내부에 있는 함수의 자세한(?) 설명은 MARK를 참조해주세요 *
 */

class ShortcutsZipViewModel: ObservableObject {
    
    @Published var userInfo: User?
    @Published var shortcutsUserLiked: [Shortcuts] = []
    @Published var shortcutsUserDownloaded: [Shortcuts] = []
    
    @Published var shortcutsMadeByUser: [Shortcuts] = []
    @Published var sortedShortcutsByDownload: [Shortcuts] = []
    @Published var curations: [Curation] = []
    
    @Published var curationsMadeByUser: [Curation] = []
    
    static let share = FirebaseService()
    private let db = Firestore.firestore()
    
    init() {
        fetchShortcutByAuthor(author: currentUser()) { shortcuts in
            self.shortcutsMadeByUser = shortcuts
        }
        fetchAllDownloadShortcut(orderBy: "numberOfDownload") { shortcuts in
            self.sortedShortcutsByDownload = shortcuts
        }
        fetchCuration { curations in
            self.curations = curations
        }
        fetchCurationByAuthor(author: currentUser()) { curations in
            self.curationsMadeByUser = curations
        }
            print("\n\n\n\n\n\n\nWHAT\n\n\n\n\n")
        fetchUser(userID: self.currentUser()) { user in
            self.userInfo = user
            print("\n\n\n\n\n\n\nWHAT\n\n\n\n\n")
            self.fetchShortcutByIds(shortcutIds: user.downloadedShortcuts) { downloadedShortcuts in
                self.shortcutsUserDownloaded = downloadedShortcuts
            }
            self.fetchShortcutByIds(shortcutIds: user.likedShortcuts) { likedShortcuts in
                self.shortcutsUserLiked = likedShortcuts
            }
        }
    }
    
    func fetchUser(userID: String, completionHandler: @escaping (User)->()) {
        
        db.collection("User")
            .whereField("id", isEqualTo: userID)
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
                        let shortcut = try decoder.decode(User.self, from: jsonData)
                        completionHandler(shortcut)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - 파이어스토어에서 모든 Shortcut을 가져오는 함수
    
    private func fetchShortcut(model: String, completionHandler: @escaping ([Shortcuts])->()) {
        var shortcuts: [Shortcuts] = []
        
        db.collection(model).getDocuments() { (querySnapshot, error) in
            if let error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let decoder = JSONDecoder()
                for document in documents {
                    do {
                        let data = document.data()
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let shortcut = try decoder.decode(Shortcuts.self, from: jsonData)
                        shortcuts.append(shortcut)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
                completionHandler(shortcuts)
            }
        }
    }
    
    // MARK: 모든 단축어를 다운로드 수로 내림차순 정렬하여 가져오는 함수
    func fetchAllDownloadShortcut(orderBy: String, completionHandler: @escaping ([Shortcuts])->()) {
        var shortcuts: [Shortcuts] = []
        
        db.collection("Shortcut")
            .order(by: orderBy, descending: true)
            .getDocuments() { (querySnapshot, error) in
                if let error {
                    print("Error getting documents: \(error)")
                } else {
                    guard let documents = querySnapshot?.documents else { return }
                    let decoder = JSONDecoder()
                    for document in documents {
                        do {
                            let data = document.data()
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let shortcut = try decoder.decode(Shortcuts.self, from: jsonData)
                            shortcuts.append(shortcut)
                        } catch let error {
                            print("error: \(error)")
                        }
                    }
                    completionHandler(shortcuts)
                }
            }
    }
    
    // MARK: - 현재 로그인한 아이디 리턴
    
    func currentUser() -> String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    // MARK: 현재 user가 만들었던 shortcuts에 대한 배열을 return하는 함수
    
    func fetchShortcutByAuthor(author: String, completionHandler: @escaping ([Shortcuts])->()) {
        
        var shortcuts: [Shortcuts] = []
        
        db.collection("Shortcut")
            .whereField("author", isEqualTo: author)
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
                            let shortcut = try decoder.decode(Shortcuts.self, from: jsonData)
                            shortcuts.append(shortcut)
                        } catch let error {
                            print("error: \(error)")
                        }
                    }
                    completionHandler(shortcuts)
                }
            }
    }
    
    //MARK: - 파이어스토어에서 모든 Curation을 가져오는 함수
    
    private func fetchCuration(completionHandler: @escaping ([Curation])->()) {
        var curations: [Curation] = []
        
        db.collection("Curation").getDocuments() { (querySnapshot, error) in
            if let error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                let decoder = JSONDecoder()
                for document in documents {
                    do {
                        let data = document.data()
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let shortcut = try decoder.decode(Curation.self, from: jsonData)
                        curations.append(shortcut)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
                completionHandler(curations)
            }
        }
    }
    
    // MARK: Author에 의한 큐레이션들 받아오는 함수
    
    func fetchCurationByAuthor (author: String, completionHandler: @escaping ([Curation])->()) {
        
        var curations: [Curation] = []
        
        db.collection("Curation")
            .whereField("author", isEqualTo: author)
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
                        let curation = try decoder.decode(Curation.self, from: jsonData)
                        curations.append(curation)
                    } catch let error {
                        print("error: \(error)")
                    }
                }
                completionHandler(curations)
            }
        }
    }
    
    // MARK: - shortcut Id 배열로 shortcut 배열 가져오는 함수
    
    func fetchShortcutByIds(shortcutIds: [String], completionHandler: @escaping ([Shortcuts])->()) {
        
        var shortcuts: [Shortcuts] = []
        
        for shortcutId in shortcutIds {
            db.collection("Shortcut")
                .whereField("id", isEqualTo: shortcutId)
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
                                let shortcut = try decoder.decode(Shortcuts.self, from: jsonData)
                                shortcuts.append(shortcut)
                            } catch let error {
                                print("error: \(error)")
                            }
                        }
                        completionHandler(shortcuts)
                    }
                }
        }
    }
    
    //TODO: Error 처리 필요
    
    func setData(model: Any) {
        switch model {
        case _ as Shortcuts:
            db.collection("Shortcut").document((model as! Shortcuts).id).setData((model as! Shortcuts).dictionary)
        case _ as Curation:
            db.collection("Curation").document((model as! Curation).id).setData((model as! Curation).dictionary)
        case _ as User:
            db.collection("User").document((model as! User).id).setData((model as! User).dictionary)
        default:
            print("this is not a model.")
        }
    }
    
    // MARK: Curation 데이터에서 Admin Curation을 분류시키는 함수
    
    func classifyAdminCuration() -> [Curation] {
        self.curations.filter {
            $0.isAdmin
        }
    }
    
    // MARK: Curation 데이터에서 User Curation을 분류시키는 함수
    
    func classifyUserCuration() -> [Curation] {
        self.curations.filter {
            !$0.isAdmin
        }
    }
}
