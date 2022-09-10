//
//  ContentView.swift
//  Video Probe
//
//  Created by Алексей Ботвин on 7/16/22.
//

import SwiftUI
import AVFoundation
import DSFDropFilesView

func secondsToString(_ seconds: Float64) -> String {
    let totalSeconds = Int(seconds)
    
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    
    if hours > 0 {
        return String(format: "%i:%02i:%02i", hours, minutes, seconds)
    } else {
        return String(format: "%02i:%02i", minutes, seconds)
    }
}

struct ContentView: View {
    @State private var filename: String = "";
    @State private var bitrate: Int = 0;
    @State private var framerate: Float = 0;
    @State private var duration: String = "00:00";
    @State private var res: CGSize = CGSize(width: 0, height: 0);
    
    var body: some View {
        VStack {
            DSFDropFilesView.SwiftUI(
                    isEnabled: true,
                    allowsMultipleDrop: false,
                    iconLabel: "Drop files here",
                    validateFiles: { urls in
                          // Check the urls, and return the appropriate drop mode
                          return .copy
                       },
                       dropFiles: { urls in
                           self.filename = urls[0].lastPathComponent
                           let video = AVAsset(url: urls[0]);
                           let track = video
                               .tracks(withMediaType: AVMediaType.video)
                               .first;
                           if track != nil {
                               let bitrate = track!.estimatedDataRate;
                               self.bitrate = Int(bitrate) / 1000
                               
                               let size = track!.naturalSize.applying(track!.preferredTransform)
                               self.res = CGSize(width: abs(size.width), height: abs(size.height))
                               
                               let framerate = track!.nominalFrameRate
                               self.framerate = framerate;
                               
                               let duration = CMTimeGetSeconds(video.duration)
                               self.duration = secondsToString(duration)
                           }
                           
                           Swift.print("\(urls)");
                           

                          return true
                       }
            )
            .frame(height: 200.0)
            
            List {
                Text("File: \(self.filename)")
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                Text("Bitrate: \(self.bitrate) kbps")
                Text("Framerate: \(String(format: "%.2f", self.framerate)) fps")
                Text("Duration: \(self.duration) m")
                Text("Width: \(Int(self.res.width)) px")
                Text("Heigh: \(Int(self.res.height)) px")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
