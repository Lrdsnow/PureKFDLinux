import Foundation

let config_filename = "purekfd_v6_config.json"

// Bash Colors
let green = "\u{001B}[0;32m"
let cyan = "\u{001B}[0;36m"
let red = "\u{001B}[0;31m"
let reg = "\u{001B}[0;0m"
//

extension URL {
    static var documents: URL {
        return URL(fileURLWithPath: "\(NSHomeDirectory())/.purekfdAppData")
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

func log(_ text: Any...) {
    let logFilePath = URL.documents.appendingPathComponent("logs.txt").path
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let timestamp = dateFormatter.string(from: Date())
    
    let logContent = text.map { "\($0)" }.joined(separator: " ")
    let logEntry = "\(timestamp): \(logContent)\n"
    NSLog(logContent)
    print(logContent)
    
    if let fileHandle = FileHandle(forWritingAtPath: logFilePath) {
        fileHandle.seekToEndOfFile()
        if let logData = logEntry.data(using: .utf8) {
            fileHandle.write(logData)
        }
        fileHandle.closeFile()
    } else {
        FileManager.default.createFile(atPath: logFilePath, contents: nil, attributes: nil)
        if let fileHandle = FileHandle(forWritingAtPath: logFilePath) {
            fileHandle.seekToEndOfFile()
            if let logData = logEntry.data(using: .utf8) {
                fileHandle.write(logData)
            }
            fileHandle.closeFile()
        }
    }
}

struct SystemInfo {
    var os: String
    var kernel: String
    var cpu: String
    var gpu: String
    var ram: String

    init() {
        self.os = "Unknown"
        self.kernel = "Unknown"
        self.cpu = "Unknown"
        self.gpu = "Unknown"
        self.ram = "Unknown"
    }

    init(os: String, kernel: String, cpu: String, gpu: String, ram: String) {
        self.os = os
        self.kernel = kernel
        self.cpu = cpu
        self.gpu = gpu
        self.ram = ram
    }
}

func getSystemInfo() -> SystemInfo {
    let distro = runCommand(command: "source /etc/os-release && echo $NAME")
    let arch = runCommand(command: "uname -m")
    let kernel = runCommand(command: "uname -r")
    let cpu = runCommand(command: "cat /proc/cpuinfo | grep 'model name' | head -n 1 | cut -d ':' -f2")
    let gpu = runCommand(command: "lspci | grep -i vga | cut -d ' ' -f 12-")
    let ram = runCommand(command: "grep MemTotal /proc/meminfo | awk '{print $2}'")
    var realRAM = "0KB"
    if let ramInKB = Int(ram) {
        let ramInGB = Double(ramInKB) / 1024.0 / 1024.0
        realRAM = "\(String(format: "%.2f", ramInGB))GB"
    } else {
        realRAM = "\(ram)KB"
    }
    return SystemInfo(os: "\(distro) \(arch)", kernel: "Linux \(kernel)", cpu: cpu, gpu: gpu, ram: realRAM)
}

func runCommand(command: String) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()

    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "N/A"
}