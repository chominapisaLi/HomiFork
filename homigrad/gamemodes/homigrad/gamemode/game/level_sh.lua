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
            StartRound()
        elseif isDeathrunMap() then
            RunConsoleCommand("hostname","HOMIFORK | DEATHRUN")
            roundActiveName = "deathrun"
            roundActiveNameNext = "deathrun"
            StartRound()
        else
            RunConsoleCommand("hostname","HOMIFORK | HOMICIDE")
            roundActiveName = "homicide"
            roundActiveNameNext = "homicide"
            StartRound() 
        end
    end
end)