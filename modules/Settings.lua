Panels.Settings = {
	-- path settings
	path = "libraries/panels/",
	imageFolder = "images/",
	audioFolder = "audio/",
	
	-- project settings
	defaultFont = nil,
	defaultFontFamily = nil,
	menuFontFamily = nil,
	resetVarsOnGameOver = true,
	
	-- panel settings
	defaultFrame = {gap = 50, margin = 8},
	snapToPanels = true,
	sequenceTransitionDuration = 750,
	borderWidth = 2,
	borderRadius = 2,
	typingSound = Panels.Audio.TypingSound.DEFAULT,
	maxScrollSpeed = 8,
	
	-- menu settings
	menuImage = "menuImage.png",
	listLockedSequences = true,
	chapterMenuHeaderImage = nil,
	useChapterMenu = true,
	showMenuOnLaunch = false,
	skipMenuOnFirstLaunch = false,
	playMenuSounds = true,

	-- credits
	showCreditsOnGameOver = false,

	-- debug
	debugControlsEnabled = false,
	listUnnamedSequences = false,
	showFPS = false,
}

local function addSlashToFolderName(f)
	if string.sub(f, -1) ~= "/" then
		f = f .. "/"
	end
	return f
end

function validateSettings() 
	local s = Panels.Settings
	s.imageFolder = addSlashToFolderName(s.imageFolder)
	s.audioFolder = addSlashToFolderName(s.audioFolder)
	s.path = addSlashToFolderName(s.path)
end

