local bgAudioPlayer = nil
local shouldResume = false
local repeatCount = 1
local typingRetainCount = 0
local typingSamplePlayer = playdate.sound.sampleplayer.new(Panels.Settings.path .. "assets/audio/typingBeep.wav")


Panels.Audio = {}

function Panels.Audio.startBGAudio(path, loop)
	bgAudioPlayer, error = playdate.sound.fileplayer.new(path)
	if bgAudioPlayer then 
		if loop then repeatCount = 0 else repeatCount = 1 end
		bgAudioPlayer:play(repeatCount)
	else 
		printError(error, "Error loading background audio:")
	end
end

function Panels.Audio.stopBGAudio() 
	if bgAudioPlayer then
		bgAudioPlayer:stop()
	end
end

function Panels.Audio.pauseBGAudio() 
	if bgAudioPlayer and bgAudioPlayer:isPlaying() then
		shouldResume = true
		bgAudioPlayer:pause()
	else
		shouldResume = false
	end
end

function Panels.Audio.resumeBGAudio()
	if bgAudioPlayer and shouldResume then
		bgAudioPlayer:play(repeatCount)
	end
end

function Panels.Audio.startTypingSound()
	typingRetainCount = typingRetainCount + 1
	typingSamplePlayer:play(0)
end

function Panels.Audio.stopTypingSound()
	typingRetainCount = typingRetainCount - 1
	
	if typingRetainCount <=0 then
		typingSamplePlayer:stop()
	end
end