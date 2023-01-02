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
	local path = Panels.Settings.path .. "assets/audio/typingBeep"
	if Panels.Settings.typingSound ~= Panels.Audio.TypingSound.NONE then
		if Panels.Settings.typingSound ~= Panels.Audio.TypingSound.DEFAULT then
			path = Panels.Settings.audioFolder .. Panels.Settings.typingSound
		end
		typingSamplePlayer = playdate.sound.sampleplayer.new(path)
	end
end

function onBGFinished(player)
	printError("", "Background audio fileplayer stopped due to buffer underrun")
end

function Panels.Audio.startBGAudio(path, loop, volume)
	if string.sub(path, -4) == ".wav" then
		path = string.sub(path, 0, -5)
	end

	if bgAudioPlayer then
		Panels.Audio.fadeOut(bgAudioPlayer)
	end
	bgAudioPlayer, error = playdate.sound.fileplayer.new(path, 2)
	if bgAudioPlayer then
		bgAudioPlayer:setFinishCallback(onBGFinished, bgAudioPlayer)
		if loop then repeatCount = 0 else repeatCount = 1 end
		success, e = bgAudioPlayer:play(repeatCount)
		if e then
			printError(e, "Error playing bg audio:")
		else
			bgAudioPlayer:setVolume(volume or 1)
		end

	else
		printError(error, "Error loading background audio:")
	end

end

function Panels.Audio.stopBGAudio()
	if bgAudioPlayer then
		bgAudioPlayer:stop()
		shouldResume = false
	end
end

function Panels.Audio.killBGAudio()
	if bgAudioPlayer then
		bgAudioPlayer:stop()
		shouldResume = false
		bgAudioPlayer = nil
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

	if typingSamplePlayer and typingRetainCount <= 0 then
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

function Panels.Audio.fadeOut(player)
	local function onFadeComplete(player)
		player:stop()
	end

	player:setVolume(0, 0, 1, onFadeComplete, player)

end
