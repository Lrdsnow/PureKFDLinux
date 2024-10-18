// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

try? FileManager.default.createDirectory(atPath: URL.documents.path, withIntermediateDirectories: true)

var repoHandler = RepoHandler()
var tweakHandler = TweakHandler()

var repos: [Repo] = []

// Bash Colors
let green = "\u{001B}[0;32m"
let cyan = "\u{001B}[0;36m"
let red = "\u{001B}[0;31m"
let reg = "\u{001B}[0;0m"
//

print("\(green)Getting Repos...\(reg)")
for url in repoHandler.repo_urls {
    do {
        let repo = try await repoHandler.getRepoAsync(url)
        repos.append(repo)
        print("\(cyan)Got Repo: \(repo.name)\(reg)")
    } catch {
        print("\(red)\(error)\(reg)")
    }
}

var packages = repos.flatMap({ $0.packages })

print("\(green)Search For Tweaks: \(reg)")
if let search = readLine() {
    if let tweak = packages.first(where: { $0.name.lowercased().contains(search.lowercased()) }) {
        print("\(green)Found Tweak:\nName: \(tweak.name)\nAuthor: \(tweak.author ?? "Unknown")\nVersion: v\(tweak.version ?? "0")\nDescription: \(tweak.description ?? "No Description")\(reg)")
        if FileManager.default.fileExists(atPath: URL.documents.appendingPathComponent("pkgs/\(tweak.bundleid)").path, isDirectory: nil) {
            print("\(green)Installed: Yes\(reg)")
        } else {
            print("\(red)Installed: No\(reg)")
            do {
                try await tweakHandler.downloadTweakAsync(pkg: tweak)
                print("\(green)Installed Successfully!\(reg)")
            } catch {
                print("\(red)Failed to download tweak: \(error.localizedDescription)\(reg)")
            }
        }
    } else {
        print("\(red)Tweak Not Found.\(reg)")
    }
}