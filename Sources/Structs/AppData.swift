//
//  AppData.swift
//  purekfd
//
//  Created by Lrdsnow on 6/28/24.
//

import Foundation
#if canImport(Combine)
import Combine

public class AppData: ObservableObject {
    @Published var repos: [Repo] = []
    @Published var pkgs: [Package] = []
    @Published var featured: [Featured] = []
    @Published var installed_pkgs: [Package] = []
    @Published var available_updates: [Package] = []
    @Published var queued_pkgs: [(Package, Double, Error?)] = [] // to install, to uninstall
    
    // Exploit stuff
    @AppStorage("selectedExploit") var selectedExploit = 0
    @AppStorage("hasSetExploit") var hasSetExploit = false
    @AppStorage("FilterPackages") var filterPackages = true
    @AppStorage("savedExploitSettings") var savedSettings: [String: String] = [:]
    
    static let shared = AppData()
}
#else
import OpenCombine

public final class AppData: ObservableObject, @unchecked Sendable {
    @Published var repos: [Repo] = []
    @Published var pkgs: [Package] = []
    @Published var featured: [Featured] = []
    @Published var installed_pkgs: [Package] = []
    @Published var available_updates: [Package] = []
    @Published var queued_pkgs: [(Package, Double, Error?)] = [] // to install, to uninstall
}
#endif 