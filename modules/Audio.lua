local bgAudioPlayer = nil
local shouldResume = false
local repeatCount = 1

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