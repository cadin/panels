local bgAudioPlayer = nil
local shouldResume = false
local repeatCount = 1
local typingRetainCount = 0
local typingSamplePlayer

local typingIsMuted = false

Panels.Audio = {
	TypingSound = {
		DEFAULT = "default",
		NONE = "none"
	}
}

function Panels.Audio.createTypingSound()
	local path = Panels.Settings.path .. "assets/audio/typingBeep.wav"
	if Panels.Settings.typingSound ~= Panels.Audio.TypingSound.NONE then
		if Panels.Settings.typingSound ~= Panels.Audio.TypingSound.DEFAULT then
			path = Panels.Settings.audioFolder .. Panels.Settings.typingSound	
		end
		typingSamplePlayer = playdate.sound.sampleplayer.new(path)
	end
end

function Panels.Audio.startBGAudio(path, loop)
	if string.sub(path, -4) == ".wav" then
		path = string.sub(path, 0, -5)
	end

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
	if bgAudioPlayer and (bgAudioPlayer:isPlaying() or shouldResume) then
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

function Panels.Audio.bgAudioIsPlaying()
	return bgAudioPlayer and bgAudioPlayer:isPlaying()
end

function Panels.Audio.startTypingSound()
	if not typingIsMuted and typingSamplePlayer then
		typingRetainCount = typingRetainCount + 1
		typingSamplePlayer:play(0)
	end
end

function Panels.Audio.stopTypingSound()
	typingRetainCount = typingRetainCount - 1
	
	if typingSamplePlayer and typingRetainCount <=0 then
		typingRetainCount = 0
		typingSamplePlayer:stop()
	end
end

function Panels.Audio.muteTypingSounds()
	if typingSamplePlayer then
		typingIsMuted = true
		typingRetainCount = 0
		typingSamplePlayer:stop()
	end
end

function Panels.Audio.unmuteTypingSounds()
	typingIsMuted = false
end