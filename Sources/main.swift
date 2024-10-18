// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

var repoHandler = RepoHandler()

var repos: [Repo] = []

print("Getting Repos...")
for url in repoHandler.repo_urls {
    do {
        let repo = try await repoHandler.getRepoAsync(url)
        repos.append(repo)
        print("Got Repo: \(repo.name)")
    } catch {
        print(error)
    }
}

var packages = repos.flatMap({ $0.packages })

print("Search For Tweaks: ")
if let search = readLine() {
    if let tweak = packages.first(where: { $0.name.lowercased().contains(search.lowercased()) }) {
        print("Found Tweak:\nName: \(tweak.name)\nAuthor: \(tweak.author ?? "Unknown")\nVersion: v\(tweak.version ?? "0")\nDescription: \(tweak.description ?? "No Description")")
    } else {
        print("Tweak Not Found.")
    }
}