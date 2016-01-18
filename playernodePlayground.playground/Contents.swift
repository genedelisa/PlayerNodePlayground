import UIKit
import AVFoundation
import XCPlayground

guard let audioFileURL = NSBundle.mainBundle().URLForResource("snare-analog", withExtension: "wav") else {
    fatalError("audio file is not in bundle.")
}

var audioFile:AVAudioFile?
do {
    audioFile = try AVAudioFile(forReading: audioFileURL)
} catch {
    fatalError("canot create AVAudioFile \(error)")
}


let engine = AVAudioEngine()
let player = AVAudioPlayerNode()

let delay = AVAudioUnitDelay()
delay.delayTime = 2
delay.feedback = 50
delay.lowPassCutoff = 15000
delay.wetDryMix = 100

let reverb = AVAudioUnitReverb()
reverb.loadFactoryPreset(.Cathedral)
reverb.wetDryMix = 50

var timePitch = AVAudioUnitTimePitch()
timePitch.pitch = 100 // cents
timePitch.rate = 2

engine.attachNode(player)
engine.attachNode(delay)
engine.attachNode(reverb)
engine.attachNode(timePitch)

let format = audioFile!.processingFormat
engine.connect(player, to: delay, format: format)
engine.connect(delay, to: reverb, format: format)
engine.connect(reverb, to: engine.mainMixerNode, format: format)


let session = AVAudioSession.sharedInstance()
do {
    try session.setCategory(AVAudioSessionCategoryPlayback)
    try session.overrideOutputAudioPort(.Speaker)
    try session.setActive(true)
} catch {
    fatalError("cannot create/set session \(error)")
}


do {
    try engine.start()
} catch {
    fatalError("Could not start engine. error: \(error).")
}


//player.scheduleFile(audioFile!, atTime: nil, completionHandler: nil)
player.scheduleFile(audioFile!, atTime: nil) {
    print("done")
    player.rate = 0.5
    player.play()
}

player.play()




XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

