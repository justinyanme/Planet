//
//  URLUtils.swift
//  Planet
//
//  Created by Shu Lyu on 2022-05-07.
//

import Foundation

struct URLUtils {
    static let applicationSupportPath = try! FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )

    static let documentsPath = try! FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )

    static let cachesPath = try! FileManager.default.url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )

    static let legacyPlanetsPath = applicationSupportPath.appendingPathComponent("planets", isDirectory: true)

    static let legacyTemplatesPath = applicationSupportPath.appendingPathComponent("templates", isDirectory: true)

    static let legacyDraftPath = applicationSupportPath.appendingPathComponent("drafts", isDirectory: true)

    static let repoPath: URL = {
        let url = documentsPath.appendingPathComponent("Planet", isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    static let templatesPath: URL = {
        let url = repoPath.appendingPathComponent("Templates", isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    static let publishedFolderHistoryPath: URL = {
        let url = repoPath.appendingPathComponent("PublishedFolders", isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    static let temporaryPath: URL = {
        let url = cachesPath.appendingPathComponent("tmp", isDirectory: true)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
}

extension URL {
    var isHTTP: Bool {
        if let scheme = scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return true
        }
        return false
    }

    var pathQueryFragment: String {
        var s = path
        if let query = query {
            s += "?\(query)"
        }
        if let fragment = fragment {
            s += "#\(fragment)"
        }
        return s
    }

    var isPlanetLink: Bool {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        if components?.scheme == "planet" && !isPlanetWindowGroupLink {
            return true
        }
        return false
    }

    var isPlanetWindowGroupLink: Bool {
        let windowGroups: [String] = ["planet://Template"]
        return windowGroups.contains(self.absoluteString)
    }
}
