util.AddNetworkString("round")
util.AddNetworkString("round_next")

local spisok = {
    ['homicide'] = 'Хомисайд',
    ['event'] = 'Ивент',
    ['homicide_extended'] = 'Хомисайд EXTENDED',
    ['bahmut'] = 'Конфликт Хомиграда',
    ['nextbot'] = 'НекстБоты',
    ['tdm'] = 'Team DeathMatch', 
    ['tiht'] = 'Trouble in tiht Town',
    ['granny'] = 'Бабка гренни',
    ['knife'] = 'Поножовщина',
    ['wick'] = 'Джон Вик',
    ['riot'] = 'RIOT',
    ['oneinnocent'] = 'Иголка в стоге сена',
    ['dm'] = 'Дезматч',
    ['hl2dm'] = 'HL2 DM',
    ['hell_yeah'] = 'HELL YEAH!!!',
    ['deathrun'] = 'DeathRun',
    ['pirate_wars'] = 'Пиратские войны',
    ['jmod_survival'] = 'Выживание',
}

function RoundActiveSync(ply)
    net.Start("round")
    net.WriteString(roundActiveName)
    local ttt = '🎈 HomiForked | '..spisok[roundActiveName]
    RunConsoleCommand("hostname",ttt)
    if ply then net.Send(ply) else net.Broadcast() end
end

function RoundActiveNextSync(ply)
    net.Start("round_next")
    net.WriteString(roundActiveNameNext)
    if ply then net.Send(ply) else net.Broadcast() end
end

function SetActiveRound(name)
    if not _G[name] then return false end
    roundActiveName = name

    RoundActiveSync()

    return true
end

function SetActiveNextRound(name)
    if not _G[name] then return false end
    roundActiveNameNext = name

    RoundActiveNextSync()

    return true
end 