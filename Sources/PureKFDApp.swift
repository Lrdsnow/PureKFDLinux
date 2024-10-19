//
//  PureKFDApp.swift
//  purekfd
//
//  Created by Lrdsnow on 10/18/24.
//

@preconcurrency import Adwaita
import OpenCombine
import Foundation
import Alamofire

@main
struct PureKFDApp: App {

    let app = AdwaitaApp(id: "uwu.lrdsnow.PureKFD.app")

    var scene: Scene {
        Window(id: "main") { window in
            MainView(app: app, window: window)
        }
        .defaultSize(width: 1100, height: 800)
    }

}

struct ToolbarView: View {

    @State private var about = false
    var app: AdwaitaApp
    var window: AdwaitaWindow

    var view: Body {
        HeaderBar.end {
            Menu(icon: .default(icon: .openMenu)) {
                MenuButton("New Window", window: false) {
                    app.addWindow("main")
                }
                .keyboardShortcut("n".ctrl())
                MenuButton("Close Window") {
                    window.close()
                }
                .keyboardShortcut("w".ctrl())
                MenuSection {
                    MenuButton("About", window: false) {
                        about = true
                    }
                }
            }
            .primary()
            .tooltip("Main Menu")
            .aboutDialog(
                visible: $about,
                app: "PureKFD",
                developer: "lrdsnow",
                version: "v7"
            )
        }
    }

}

struct MainView: View {
    var app: AdwaitaApp
    var window: AdwaitaWindow

    @State private var repos: [Repo] = []
    @State private var installedTweaks: [Package] = []
    @State private var systemInfo: SystemInfo = SystemInfo()

    @State private var tab: Int = 0
    @State private var selectedRepo: Repo? = nil
    @State private var selectedPackage: Package? = nil

    var view: Body {
        NavigationSplitView(sidebar: {
            VStack {
                Button("Installed", icon: .default(icon: .folderDownload), handler: {
                    tab = 0
                }).padding(2)
                Button("Settings", icon: .default(icon: .info), handler: {
                    tab = 1
                }).padding(2)
                PreferencesGroup("Repos", content: {
                    ForEach(repos) { repo in
                        Button("\(repo.name)", handler: {
                            selectedRepo = repo
                            tab = 2
                        }).padding(2)
                    }
                })
            }.backgroundStyle(true)
        }, content: {
            if tab == 0 {
                Text("Installed").title2(true)
                ForEach(installedTweaks) { pkg in
                    Button(pkg.name, handler: {

                    }).padding(2)
                }
            } else if tab == 1 {
                Text("Settings").title2(true)
                Text(systemInfo.os)
                Text(systemInfo.kernel)
                Text(systemInfo.cpu)
                Text(systemInfo.gpu)
                Text(systemInfo.ram)
            } else if tab == 2 {
                if let repo = selectedRepo {
                    VStack {
                        Text(repo.name).title2(true)
                        ForEach(repo.packages) { pkg in
                            Button("\(pkg.name)", handler: {
                                selectedPackage = pkg
                                tab = 3
                            }).padding(2)
                        }
                    }
                }
            } else if tab == 3 {
                if let pkg = selectedPackage {
                    Text(pkg.name)
                    Text(pkg.author ?? "Unknown Author")
                    Text(pkg.long_description ?? pkg.description ?? "No Description")
                    Button("Install Tweak", handler: {
                        Task {
                            print("\(cyan)Installing \(pkg.name)...\(reg)")
                            do {
                                try await TweakHandler.downloadTweakAsync(pkg: pkg)
                                print("\(green)Installed Successfully!\(reg)")
                            } catch {
                                print("\(red)Failed to download tweak: \(error.localizedDescription)\(reg)")
                            }
                        }
                    }).pill().halign(.center).padding()
                }
            }
        })
        .padding()
        .topToolbar {
            ToolbarView(app: app, window: window)
        }
        .onAppear {
            getRepos()
        }
    }

    func getRepos() {
        Task {
            for url in RepoHandler().repo_urls {
                do {
                    var repo = try await RepoHandler().getRepoAsync(url)
                    Idle {
                        repos.append(repo)
                        print("\(cyan)Got Repo: \(repo.name)\(reg)")
                    }
                } catch {
                    print("\(red)\(error)\(reg)")
                }
            }
        }
        Task {
            for folder in (try? FileManager.default.contentsOfDirectory(atPath: URL.documents.appendingPathComponent("pkgs").path)) ?? [] {
                let infoURL = URL.documents.appendingPathComponent("pkgs/\(folder)/_info.json")
                if FileManager.default.fileExists(atPath: infoURL.path, isDirectory: nil),
                    let data = try? Data(contentsOf: infoURL),
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let pkg = Package(json, nil, nil)
                        Idle {
                            installedTweaks.append(pkg)
                            print("\(green)Found Installed Tweak: \(pkg.name)\(reg)")
                        }
                } else {
                    print("\(red)Failed to read tweak: \(folder)\(reg)")
                }
            }
        }
        Task {
            let sysInfo = getSystemInfo()
            Idle {
                systemInfo = sysInfo
            }
        }
    }
}