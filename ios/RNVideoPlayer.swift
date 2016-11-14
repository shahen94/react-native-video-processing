//
//  RNVideoPlayer.swift
//  RNVideoProcessing
//
//  Created by Simply Technologies on 11/14/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import Foundation

@objc(RNVideoPlayer)
class RNVideoPlayer: RCTView {

    var source: NSString? {
        set {
            configure()
        }
        get {
            return nil
        }
    }

    var currentTime: NSNumber? {
        set {
        }
        get {
            return nil
        }
    }

    var startTime: NSNumber? {
        set {
        }
        get {
            return nil
        }
    }

    var endTime: NSNumber? {
        set {
        }
        get {
            return nil
        }
    }
    
    func configure() {
        let renderView = RenderView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        renderView.backgroundColor = UIColor.green
        self.addSubview(renderView)
        let bundleURL = Bundle.main.resourceURL!
        let movieURL = URL(string: "Simons_Cat.mp4", relativeTo: bundleURL)!
        let sepiot = SepiaToneFilter()
        
        do {
            movie = try MovieInput(url: movieURL, playAtActualSpeed: true, loop: true)
            
            movie --> sepiot --> renderView
            movie.runBenchmark = true;
            movie.start()
        } catch {
            print("Something went wrong: \(error)")
        }
    }
}
