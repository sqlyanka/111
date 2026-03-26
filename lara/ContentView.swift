//
//  ContentView.swift
//  lara
//
//  Created by ruter on 23.03.26.
//

import SwiftUI
import notify

struct ContentView: View {
    @ObservedObject private var mgr = laramgr.shared
    @State private var uid: uid_t = getuid()
    @State private var pid: pid_t = getpid()
    @State private var hasKernelcacheOffsets = lara_has_kernproc_offset()
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                if !hasKernelcacheOffsets {
                    Section("Kernelcache") {
                        Button("Download Kernelcache") {
                            DispatchQueue.global(qos: .userInitiated).async {
                                let ok = lara_download_kernelcache_and_set_offsets()
                                DispatchQueue.main.async {
                                    hasKernelcacheOffsets = ok
                                }
                            }
                        }
                    }
                } else {
                    Section("Kernel Read Write") {
                        Button(mgr.dsrunning ? "Running..." : "Run Exploit") {
                            mgr.run()
                        }
                        .disabled(mgr.dsrunning)
                        
                        HStack {
                            Text("krw ready?")
                            Spacer()
                            Text(mgr.dsready ? "Yes" : "No")
                                .foregroundColor(mgr.dsready ? .green : .red)
                        }
                        
                        if hasKernelcacheOffsets {
                            HStack {
                                Text("kernproc:")
                                Spacer()
                                Text(String(format: "0x%llx", lara_get_kernproc_offset()))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("kernel_base:")
                            Spacer()
                            Text(String(format: "0x%llx", mgr.kernbase))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("kernel_slide:")
                            Spacer()
                            Text(String(format: "0x%llx", mgr.kernslide))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section("Kernel File System") {
                        Button("Initialize KFS") {
                            mgr.kfsinit()
                        }
                        .disabled(!mgr.dsready)
                        
                        Button("Apply Comic Sans MS") {
                            let success = mgr.kfsoverwrite(target: laramgr.fontpath, withBundledFont: "Comic Sans MS")
                            
                            if success {
                                mgr.logmsg("Font changed to Comic Sans MS")
                            } else {
                                mgr.logmsg("Failed to change font")
                            }
                        }
                        .disabled(!mgr.kfsready)
                        
                        Button("Restore Original Font") {
                            let success = mgr.kfsoverwrite(target: laramgr.fontpath, withBundledFont: "SFUI")
                            if success {
                                mgr.logmsg("Font restored to original SFUI")
                            } else {
                                mgr.logmsg("Failed to restore font")
                            }
                        }
                        .disabled(!mgr.kfsready)
                        
                        Button("Respring") {
                            notify_post("com.apple.springboard.toggleLockScreen")
                        }
                        .disabled(!mgr.kfsready)
                        
                        HStack {
                            Text("UID:")
                            
                            Spacer()
                            
                            Text("\(uid)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Button {
                                uid = getuid()
                                print(uid)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        
                        HStack {
                            Text("PID:")
                            
                            Spacer()
                            
                            Text("\(pid)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                            
                            Button {
                                pid = getpid()
                                print(pid)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    
                    Section {
                        Button("respring") {
                            notify_post("com.apple.springboard.toggleLockScreen")
                        }
                        .disabled(!mgr.dsready)
                        
                        Button("panic!") {
                            mgr.panic()
                        }
                        .disabled(!mgr.dsready)
                    } header: {
                        Text("Other")
                    }
                }
                
                Section {
                    HStack(alignment: .top) {
                        AsyncImage(url: URL(string: "https://github.com/rooootdev.png")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text("roooot")
                                .font(.headline)
                            
                            Text("Main Developer")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                        
                        Spacer()
                    }
                    .onTapGesture {
                        if let url = URL(string: "https://github.com/rooootdev"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        AsyncImage(url: URL(string: "https://github.com/AppInstalleriOSGH.png")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text("AppInstaller iOS")
                                .font(.headline)
                            
                            Text("Helped me with offsets and other stuff. This project wouldnt have been possible without him!")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                        
                        Spacer()
                    }
                    .onTapGesture {
                        if let url = URL(string: "https://github.com/khanhduytran0"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                } header: {
                    Text("Credits")
                }
            }
            .navigationTitle("lara")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showResetAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            if !hasKernelcacheOffsets {
                DispatchQueue.global(qos: .userInitiated).async {
                    let ok = lara_download_kernelcache_and_set_offsets()
                    DispatchQueue.main.async {
                        hasKernelcacheOffsets = ok
                    }
                }
            }
        }
        .alert("Clear Kernelcache Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                lara_clear_kernelcache_data()
                hasKernelcacheOffsets = lara_has_kernproc_offset()
            }
        } message: {
            Text("This will delete the downloaded kernelcache and remove saved offsets.")
        }
    }
}
