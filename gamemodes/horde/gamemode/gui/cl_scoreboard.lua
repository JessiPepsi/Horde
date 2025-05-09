if GetConVarNumber("horde_enable_scoreboard") == 0 then return end

local scoreboard = {}

local draw_SimpleText = draw.SimpleText

local draw_RoundedBoxEx = draw.RoundedBoxEx
local draw_RoundedBox = draw.RoundedBox

local player_GetAll = player.GetAll

local server_name = GetHostName()
local map_name = game.GetMap()

local color_black_alpha120 = Color(0,0,0,120)

-- EasyLabel
function HORDE:EasyLabel(parent, text, font, textcolor)
	local ELpanel = vgui.Create("DLabel", parent)
	if font then
		ELpanel:SetFont(font or "DefaultFont")
	end
	ELpanel:SetText(text)
	ELpanel:SizeToContents()
	if textcolor then
		ELpanel:SetTextColor(textcolor)
	end
	ELpanel:SetKeyboardInputEnabled(false)
	ELpanel:SetMouseInputEnabled(false)

	return ELpanel
end

function scoreboard:show()

	local width = ScrW() * 0.6
	local height = ScrH() * 0.65

	local title = vgui.Create("DPanel")
	title:SetSize(width, height)
	title:AlignTop( ScrH() * 0.15 )
	--title:SetPos(ScrW()/2 - 1000 / 2, ScrH()/5 - 50)
	title:CenterHorizontal()
	function title:Paint(w, h)
		draw.RoundedBoxEx(8,0,0,w,h * 0.135, Color(30,30,30,150), true, true, false,false)
		draw_SimpleText("Horde - " .. map_name .. " - " .. HORDE.Difficulty[HORDE.CurrentDifficulty].name, "Title", 10, 12, HORDE.color_crimson_dim, TEXT_ALIGN_LEFT)
		draw_SimpleText(server_name, "Title", width - 10, 12, HORDE.color_crimson_dim, TEXT_ALIGN_RIGHT)
	end

	local header = title:Add("DHeaderPanel")
	header:Dock(TOP)
	header:SetSize(title:GetWide(), 45)
	header:DockMargin(0,50,0,0)

	local board = title:Add("DPanel")
	board:Dock(FILL)
	board:SetSize(width)
	--board:AlignTop( ScrH() * 0.25 )
	board:CenterHorizontal()
	--board:SetPos(ScrW()/2-(1000/2), ScrH()/5)
	function board:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(30,30,30,150))
	end

	local ScrollPanel = board:Add("DScrollPanel")
	ScrollPanel:Dock(FILL)

	local Bar = ScrollPanel:GetVBar()
	local butC = 0

	-- Paint ScrollBar
	function Bar:Paint(w,h)
		draw.RoundedBox(8,  w / 2 - w / 2, butC, w / 2, h - butC * 2, color_black_alpha120 )
	end

	function Bar.btnDown:Paint(w,h)
	end

	function Bar.btnUp:Paint(w,h)
		butC = h
	end

	function Bar.btnGrip:Paint(w,h)
		draw.RoundedBox(8,  w / 2 - w / 2, 0, w / 2, h, color_black)
	end
	local PlayerPanels
	if PlayerPanels == nil then
		PlayerPanels = {}
	end

	local function RemovePlayerPanel(panel)
		if panel:IsValid() then
			PlayerPanels[panel:GetPlayer()] = nil
			panel:Remove()
		end
	end

	for pl, panel in pairs(PlayerPanels) do
		if not panel:IsValid() or pl:IsValid() and pl:IsSpectator() then
			RemovePlayerPanel(panel)
		end
	end

	local function GetPlayerPanel(pl)
		for _, panel in pairs(PlayerPanels) do
			if panel:IsValid() and panel:GetPlayer() == pl then
				return panel
			end
		end
	end

	local function CreatePlayerPanel(pl)
		local curpan = GetPlayerPanel(pl)
		if curpan and curpan:IsValid() then return curpan end

		local panel = ScrollPanel:Add("DPlayerLine")
		panel:SetPlayer(pl)
		panel:Dock(TOP)
		panel:DockMargin(ScrollPanel:GetWide() * 0.01, 2, ScrollPanel:GetWide() * 0.01, 2)

		PlayerPanels[pl] = panel

		return panel
	end

	board:SizeToChildren(true, false)

	local player_score = {}
	for _, ply in pairs(player.GetAll()) do
		player_score[ply] = ply:Frags()
	end

	for ply, _ in SortedPairsByValue(player_score, true) do
		CreatePlayerPanel(ply)
	end

	local playerSelectorButton = vgui.Create( "DButton" )
	scoreboard.PlayerSelectorButton = playerSelectorButton
	playerSelectorButton:SetText( "Default player model" )
	playerSelectorButton:SetSize( 200, 40 )
	playerSelectorButton:SetPos( 5, ScrH() / 2 - 25 )
	playerSelectorButton:SetTextColor( Color( 255, 255, 255 ) )
	function playerSelectorButton:DoClick()
		RunConsoleCommand( "open_playermodel_selector" )
	end

	function playerSelectorButton:Paint( w, h )
		if self:IsHovered() then
			draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
		else
			draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
		end
	end

	local offset = 25
	if outfitter and outfitter.GUIOpen then
		local outfitterButton = vgui.Create( "DButton" )
		scoreboard.OutfitterButton = outfitterButton
		outfitterButton:SetText( "Outfitter" )
		outfitterButton:SetSize( 200, 40 )
		outfitterButton:SetPos( 5, ScrH() / 2 + offset )
		outfitterButton:SetTextColor( Color( 255, 255, 255 ) )

		function outfitterButton:DoClick()
			outfitter.GUIOpen()
		end

		function outfitterButton:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end

		offset = offset + 50
	end

	if FITTR then -- Mutually exclusive with outfitter
		local outfitterButton = vgui.Create( "DButton" )
		scoreboard.OutfitterButton = outfitterButton
		outfitterButton:SetText( "Fittr" )
		outfitterButton:SetSize( 200, 40 )
		outfitterButton:SetPos( 5, ScrH() / 2 + offset )
		outfitterButton:SetTextColor( Color( 255, 255, 255 ) )

		function outfitterButton:DoClick()
			RunConsoleCommand( "fittr" )
		end

		function outfitterButton:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end

		offset = offset + 50
	end

	if hook.GetTable().HUDPaint and hook.GetTable().HUDPaint["SimpleTP.HUDPaint"] then
		local thirdPerson = vgui.Create( "DButton" )
		scoreboard.ThirdPerson = thirdPerson
		thirdPerson:SetText( "Third Person" )
		thirdPerson:SetSize( 200, 40 )
		thirdPerson:SetPos( 5, ScrH() / 2 + offset )
		thirdPerson:SetTextColor( Color( 255, 255, 255 ) )

		function thirdPerson:DoClick()
			-- Weird global from Simple Third Person
			local frame = vgui.Create( "DFrame" )
			BuildMenu( frame )
			frame:SetSize( 300, 200 )
			frame:Center()
			frame:MakePopup()
		end

		function thirdPerson:Paint( w, h )
			if self:IsHovered() then
				draw_RoundedBox( 8, 0, 0, w, h, Color( 30, 30, 30, 255 ) )
			else
				draw_RoundedBox( 8, 0, 0, w, h, Color( 40, 40, 40, 255 ) )
			end
		end

		offset = offset + 50
	end

	function scoreboard:hide()
		-- This is where you hide the scoreboard, such as with Base:Remove()`
		for _, panel in pairs( PlayerPanels ) do
			if panel.SubMenu then
				panel.SubMenu:Remove()
			end
		end
		gui.EnableScreenClicker(false)
		board:Remove()
		title:Remove()
		if IsValid(self.ThirdPerson) then
			self.ThirdPerson:Remove()
		end

		if IsValid(self.OutfitterButton) then
			self.OutfitterButton:Remove()
		end

		if IsValid(self.PlayerSelectorButton) then
			self.PlayerSelectorButton:Remove()
		end

		hook.Remove("KeyPress", "Horde_Scoreboard_Mouse")
	end

	hook.Add("KeyPress", "Horde_Scoreboard_Mouse", function(ply, key)
		if board and title and (key == IN_ATTACK or key == IN_ATTACK2 or key == IN_USE) then
			gui.EnableScreenClicker(true)
		end
	end)
end

function GM:ScoreboardShow()
	scoreboard:show()
end

function GM:ScoreboardHide()
    if not scoreboard then return end
	scoreboard:hide()
end
