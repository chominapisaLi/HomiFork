local map = game.GetMap()
if map ~= "mg_piratewars_remake" then return end
hook.Add("Player Think","mapsprekol", function(ply)
	SetActiveNextRound('tdm')
end)