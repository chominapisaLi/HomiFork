LevelList = {}

function TableRound(name) return _G[name or roundActiveName] end
local function isDeathrunMap()
    local mapName = game.GetMap() -- Получаем имя текущей карты
    return string.find(mapName, "deathrun") ~= nil -- Проверяем, содержит ли имя карты "deathrun"
end
timer.Simple(0,function()
    if roundActiveName == nil then -- SetActiveNextRound('tdm')
        if game.GetMap() == 'mg_piratewars_remake' then
            RunConsoleCommand("hostname","HOMIFORK | PirateWars")
            roundActiveName = "pirate_wars"
            roundActiveNameNext = "pirate_wars"
            RTV_CountRoundDefault = 10
            StartRound()
        elseif isDeathrunMap() then
            RunConsoleCommand("hostname","HOMIFORK | DEATHRUN")
            roundActiveName = "deathrun"
            roundActiveNameNext = "deathrun"
            RTV_CountRoundDefault = 5
            StartRound()
        else
            RunConsoleCommand("hostname","HOMIFORK | HOMICIDE")
            roundActiveName = "homicide"
            roundActiveNameNext = "homicide"
            StartRound() 
        end
    end
end)