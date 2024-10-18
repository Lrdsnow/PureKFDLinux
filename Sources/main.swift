// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

var repoHandler = RepoHandler()

print("Getting Repos...")
for url in repoHandler.repo_urls {
    do {
        let repo = try await repoHandler.getRepoAsync(url)
        print("Got Repo: \(repo.name)")
    } catch {
        print(error)
    }
}