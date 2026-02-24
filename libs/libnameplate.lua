local _G = ShaguTweaks.GetGlobalEnv()
local GetExpansion = ShaguTweaks.GetExpansion
local GetUnitData = ShaguTweaks.GetUnitData

local NAMEPLATE_OBJECTORDER = { "border", "glow", "name", "level", "levelicon", "raidicon" }
local NAMEPLATE_TYPE = "Button"
if GetExpansion() == "tbc" then
  NAMEPLATE_OBJECTORDER = { "border", "castborder", "casticon", "glow", "name", "level", "levelicon", "raidicon" }
  NAMEPLATE_TYPE = "Frame"
end

local function IsNamePlate(frame)
  if frame:GetObjectType() ~= NAMEPLATE_TYPE then return nil end
  regions = frame:GetRegions()

  if not regions then return nil end
  if not regions.GetObjectType then return nil end
  if not regions.GetTexture then return nil end

  if regions:GetObjectType() ~= "Texture" then return nil end
  return regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" or nil
end

local registry = {}
local initialized = 0
local parentcount, childs, plate
ShaguTweaks.libnameplate = CreateFrame("Frame", nil, UIParent)
ShaguTweaks.libnameplate.OnInit = {}
ShaguTweaks.libnameplate.OnShow = {}
ShaguTweaks.libnameplate.OnUpdate = {}
ShaguTweaks.libnameplate:SetScript("OnUpdate", function()
  if not this.tick then this.tick = GetTime() + .2 end
  if this.tick > GetTime() then return end
  this.tick = GetTime() + .2

  parentcount = WorldFrame:GetNumChildren()
  if initialized < parentcount then
    childs = { WorldFrame:GetChildren() }
    for i = initialized + 1, parentcount do
      plate = childs[i]

      if IsNamePlate(plate) and not registry[plate] then
        plate.healthbar = plate:GetChildren()
        local regions = {plate:GetRegions()}
        for i = 1, table.getn(regions) do
          if plate and NAMEPLATE_OBJECTORDER[i] then
            plate[NAMEPLATE_OBJECTORDER[i]] = regions[i]
          end
        end

        -- run OnInit functions
        local onInits = ShaguTweaks.libnameplate.OnInit
        for i = 1, table.getn(onInits) do
          onInits[i](plate)
        end

        -- register OnUpdate functions
        local oldUpdate = plate:GetScript("OnUpdate")
        plate:SetScript("OnUpdate", function(self, elapsed)
          if oldUpdate then oldUpdate(self, elapsed) end
          local onUpdates = ShaguTweaks.libnameplate.OnUpdate
          for i = 1, table.getn(onUpdates) do
            onUpdates[i](self, elapsed)
          end
        end)

        -- register OnShow functions
        local oldShow = plate:GetScript("OnShow")
        plate:SetScript("OnShow", function(self)
          if oldShow then oldShow(self) end
          local onShows = ShaguTweaks.libnameplate.OnShow
          for i = 1, table.getn(onShows) do
            onShows[i](self)
          end
        end)

        registry[plate] = plate
      end
    end

    initialized = parentcount
  end
end)
