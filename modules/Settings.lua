Panels.Settings = {
	-- path settings
	path = "libraries/panels/",
	comicData = {},
	credits = {},
	imageFolder = "images/",
	audioFolder = "audio/",
	
	-- panel settings
	defaultFrame = {gap = 50, margin = 8},
	snapToPanels = true,
	sequenceTransitionDuration = 750,
	defaultFont = nil,
	
	-- menu settings
	menuImage = "menuImage.png",
	listUnnamedSequences = true,
	listLockedSequences = true,
	chapterMenuHeaderImage = nil,
	useCreditsMenu = true,
	useChapterMenu = true,
	useMainMenu = false,
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

