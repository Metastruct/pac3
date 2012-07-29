local L = pace.LanguageString
local PANEL = {}

PANEL.ClassName = "browser"
PANEL.Base = "DListView"

PANEL.Dir = ""
AccessorFunc(PANEL, "Dir", "Dir")

function PANEL:SetDir(str)
	self.Dir = str
	self:PopulateFromClient()
end

function PANEL:Init()
	self:AddColumn(L"name")
	self:AddColumn(L"size")
	self:AddColumn(L"modified")
	self:PopulateFromClient()
	self:FixColumnsLayout()
end

local function OnMousePressed(self, mcode)
	if mcode == MOUSE_RIGHT then
		self:GetListView():OnRowRightClick(self:GetID(), self)
	elseif mcode == MOUSE_LEFT then
		self:GetListView():OnClickLine(self, true)
		self:OnSelect()
	end
end

function PANEL:AddOutfits(folder, callback)
	for i, name in pairs(file.Find(folder.."*", _G.net and "DATA" or nil)) do
		if name:find("%.txt") then
			local outfit = folder .. name
			if file.Exists(outfit, _G.net and "DATA" or nil) then
				local filenode = self:AddLine(
					name:gsub("%.txt", ""), 
					string.NiceSize(file.Size(outfit, _G.net and "DATA" or nil)), 
					os.date("%m/%d/%Y %H:%M", file.Time(outfit, _G.net and "DATA" or nil))
				)
				filenode.FileName = name
				filenode.OnSelect = callback
				filenode.OnMousePressed = OnMousePressed
			end
		end
	end
end

function PANEL:PopulateFromClient()
	self:Clear()
	
	self:AddOutfits("pac3/" .. self.Dir, self.OnLoad or function(node)
		pace.LoadPartFromFile(pace.current_part, node.FileName)
		pace.RefreshTree()
	end)		
end

function PANEL:OnRowRightClick(id, line)
	local menu = DermaMenu()
	menu:SetPos(gui.MouseX(),gui.MouseY())
	menu:MakePopup()
	menu:AddOption(L"rename", function()
		Derma_StringRequest(L"rename", L"type the new name:", line.name, function(text)
			
			local c = file.Read(line.FileName)
			file.Delete(line.FileName, _G.net and "DATA" or nil)
			file.Write(line.FileName, c, _G.net and "DATA" or nil)
			
			self:PopulateFromClient()
		end)
	end)
	
	menu:AddOption(L"delete", function()
		file.Delete("pac3/" .. self.Dir .. line.FileName, _G.net and "DATA" or nil)
		self:PopulateFromClient()
	end)
end

pace.RegisterPanel(PANEL)