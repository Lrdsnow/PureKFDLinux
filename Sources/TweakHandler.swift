//
//  TweakHandler.swift
//  purekfd
//
//  Created by Lrdsnow on 10/18/24.
//

import Foundation
import Alamofire
import Zip
#if canImport(Combine)
import Combine
import JASON
#else
import OpenCombine

@preconcurrency
import JASON
#endif 

func findFileOrFolder(_ url: URL, _ names: [String]) -> [URL] {
    var result = [URL]()
    let fileManager = FileManager.default
    
    guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) else {
        return result
    }
    
    for case let fileURL as URL in enumerator {
        if names.contains(fileURL.lastPathComponent) {
            result.append(fileURL)
        }
    }
    
    return result
}

func downloadTweakAsync(pkg: Package) async throws {
    let response = await AF.request(pkg.path!).serializingData().response

    switch response.result {
    case .success(let data):
        let json = JASON.JSON(data)
        let pkgs_dir = URL.documents.appendingPathComponent("pkgs")
        let fm = FileManager.default
        try? fm.createDirectory(at: pkgs_dir, withIntermediateDirectories: true)
        var unzipdir: URL? = nil
        let url = fm.temporaryDirectory.appendingPathComponent("\(UUID()).zip")
        try data.write(to: url)
        unzipdir = try Zip.quickUnzipFile(url)
        let pkg_dir = pkgs_dir.appendingPathComponent(pkg.bundleid)
        let unzip_pkg_dir = unzipdir!.appendingPathComponent(pkg.bundleid)
        if fm.fileExists(atPath: unzip_pkg_dir.appendingPathComponent("tweak.json").path) || fm.fileExists(atPath: unzip_pkg_dir.appendingPathComponent("Overwrite").path) {
            try fm.moveItem(at: unzip_pkg_dir, to: pkg_dir)
        } else {
            if let folder = findFileOrFolder(unzip_pkg_dir, ["tweak.json", "Overwrite"]).first?.deletingLastPathComponent() {
                try fm.moveItem(at: folder, to: pkg_dir)
            } else {
                throw "Tweak folder was not found in package!"
            }
        }
        // less code, and we dont have to worry about optimization bcuz its the download process
        let temp_tweak_json_data = (try? JSONEncoder().encode(pkg)) ?? Data()
        var temp_tweak = Package((try? JSONSerialization.jsonObject(with: temp_tweak_json_data, options: []) as? [String: Any]) ?? [:], pkg.repo, nil)
        //
        try? fm.moveItem(at: temp_tweak.pkgpath.appendingPathComponent("overwrite"), to: temp_tweak.pkgpath.appendingPathComponent("Overwrite")) // fix common issue
        try? fm.moveItem(at: temp_tweak.pkgpath.appendingPathComponent("restore"), to: temp_tweak.pkgpath.appendingPathComponent("Restore")) // fix common issue 2
        temp_tweak.repo = nil
        temp_tweak.installed = true
        #if canImport(Combine)
        let configJsonPath = pkg_dir.appendingPathComponent(config_filename).path
        if !temp_tweak.hasprefs {
            if let error = quickConvertLegacyEncrypted(pkg_dir: pkg_dir, configJsonPath: configJsonPath) {
                if !error.contains("does not exist") {
                    temp_tweak.error = error
                }
            } else {
                temp_tweak.hasprefs = true
            }
        }
        if !temp_tweak.hasprefs {
            if let error = quickConvertPicasso(pkg_dir: pkg_dir, configJsonPath: configJsonPath) {
                if !error.contains("does not exist") {
                    temp_tweak.error = error
                }
            } else {
                temp_tweak.hasprefs = true
            }
        }
        if !temp_tweak.hasprefs {
            if let error = quickConvertLegacyPKFD(pkg_dir: pkg_dir, configJsonPath: configJsonPath) {
                if !error.contains("does not exist") {
                    temp_tweak.error = error
                }
            } else {
                temp_tweak.hasprefs = true
            }
        }
        if !temp_tweak.hasprefs {
            temp_tweak.hasprefs = fm.fileExists(atPath: configJsonPath)
        }
        if FileManager.default.fileExists(atPath: pkg_dir.appendingPathComponent("tweak.json").path) {
            if let error = quickConvertLegacyTweak(pkg: temp_tweak) {
                temp_tweak.error = error
            }
        }
        if let error = quickConvertLegacyOverwriteTweak(pkg: temp_tweak) {
            temp_tweak.error = error
        }
        #endif
        let jsonData = try JSONEncoder().encode(temp_tweak)
        try jsonData.write(to: pkg_dir.appendingPathComponent("_info.json"))
        if let unzipdir = unzipdir {
            try? fm.removeItem(at: unzipdir)
        }
        try? fm.removeItem(at: url)
        return
    case .failure(let error):
        throw error
    }

    throw "Unknown Error"
}