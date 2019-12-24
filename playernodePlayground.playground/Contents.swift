
/*:
 # AVAudioPlayerNode
 How to read a sound file, add effects, and play the damn thing.
 */

import AVFoundation
import PlaygroundSupport

//: Create the angine
let engine = AVAudioEngine()

//: Create a few effects
let delay = AVAudioUnitDelay()
delay.delayTime = 2
delay.feedback = 50
delay.lowPassCutoff = 15000
delay.wetDryMix = 100

let reverb = AVAudioUnitReverb()
reverb.loadFactoryPreset(.cathedral)
reverb.wetDryMix = 50

var timePitch = AVAudioUnitTimePitch()
timePitch.pitch = 100 // cents
timePitch.rate = 2

//: Finally, create the star of the show
let player = AVAudioPlayerNode()

//: Now we have 3 nodes. Attach them to the engine to use them. The order doesn't matter here.
engine.attach(player)
engine.attach(delay)
engine.attach(reverb)
engine.attach(timePitch)

//: Read the sound file. It's in the Resources folder.

// mp3 seems to hang
// guard let audioFileURL = Bundle.main.url(forResource: "jfk", withExtension: "mp3") else {

// wav works
guard let audioFileURL = Bundle.main.url(forResource: "snare-analog", withExtension: "wav") else {
    fatalError("audio file is not in bundle.")
}

var audioFile: AVAudioFile?
do {
    audioFile = try AVAudioFile(forReading: audioFileURL)
} catch {
    fatalError("canot create AVAudioFile \(error)")
}

//: If this fails, you messed up. Is the sound file there?
if let soundFile = audioFile {
    
    //: Now create the "graph". You can have fun here trying different connections.
    let format = soundFile.processingFormat
    engine.connect(player, to: delay, format: format)
    engine.connect(delay, to: reverb, format: format)
    engine.connect(reverb, to: engine.mainMixerNode, format: format)
    
    //: macOS doesn't have an audio session, so do this check.
    #if os(iOS) || os(watchOS) || os(tvOS)
    let session = AVAudioSession.sharedInstance()
    do {
        try session.setCategory(AVAudioSession.Category.playback)
        try session.overrideOutputAudioPort(.speaker)
        try session.setActive(true)
    } catch {
        fatalError("cannot create/set session \(error)")
    }
    #endif
    
    //: Start your engines!
    do {
        try engine.start()
    } catch {
        fatalError("Could not start engine. error: \(error).")
    }
    
    //: Now play it! See the docs for the time thing. nil means "now".
    let when: AVAudioTime? = nil
    player.scheduleFile(soundFile, at: when) {
        print("scheduled now")
        // just for fun
        player.rate = 0.5
        player.play()
    }
    
    //: or just play
    // player.play()
}

//: you might not hear anything if you don't do this. You'll have to hit the stop button.
PlaygroundPage.current.needsIndefiniteExecution = true
