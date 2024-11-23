LevelList = {}

function TableRound(name) return _G[name or roundActiveName] end

timer.Simple(0,function()
    if roundActiveName == nil then
        RunConsoleCommand("hostname HOMIFORK")
        roundActiveName = "homicide"
        roundActiveNameNext = "homicide"
        StartRound()
    end
end)