hook.Add("PermaProps.OnAdd", "PermaProps.Ragdoll", function(ent, data, ply)
    if ent:GetClass() == "prop_ragdoll" then
        data.bones = data.bones or {}
        local num = ent:GetPhysicsObjectCount()
        for objId = 0, num - 1 do

            local obj = ent:GetPhysicsObjectNum( objId )
            if not obj:IsValid() then continue end

            data.bones[objId] = {}

            data.bones[objId].Pos = obj:GetPos()
            data.bones[objId].Angle = obj:GetAngles()
            data.bones[objId].Frozen = !obj:IsMoveable()

            data.bones[objId].Pos, data.bones[objId].Angle = WorldToLocal( data.bones[objId].Pos, data.bones[objId].Angle, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )

        end

    end
end)

hook.Add("PermaProps.PostSpawn", "PermaProps.Ragdoll", function(ent, data)
    if ent:GetClass() == "prop_ragdoll" then
        if data.bones then
            for objId, objectdata in pairs(data.bones) do

                local Phys = ent:GetPhysicsObjectNum(objId)
                if !IsValid(Phys) then continue end
            
                if (isvector(objectdata.Pos) && isangle(objectdata.Angle)) then
    
                    local pos, ang = LocalToWorld(objectdata.Pos, objectdata.Angle, Vector(0, 0, 0), Angle(0, 0, 0))
                    Phys:SetPos(pos)
                    Phys:SetAngles(ang)
                    Phys:Wake()
    
                    if objectdata.Frozen then
                        Phys:EnableMotion(false)
                    end
    
                end
            
            end
        end
    end
end)

hook.Add("InitPostEntity", "PermaProps.TextscreenIntegration", function()
    hook.Add("PermaProps.OnAdd", "PermaProps.Textscreens", function(ent, data, ply)
        if ent:GetClass() == "sammyservers_textscreen" then
            data.lines = ent.lines or {}
            data.model = "models/squad/sf_plates/sf_plate3x3.mdl"
        end
    end)
    
    hook.Add("PermaProps.PreSpawn", "PermaProps.Textscreens", function(ent, data, ply)
        if ent:GetClass() == "sammyservers_textscreen" then
            if data.lines then
                for key, line in pairs(data.lines) do
                    ent:SetLine(key, line.text, Color(line.color.r, line.color.g, line.color.b, line.color.a), line.size, line.font, line.rainbow or 0)
                end
            end
        end
    end)
end)

hook.Add("PermaProps.OnAdd", "PermaProps.343", function(ent, data, ply)
    if ent:GetClass() == "prop_effect" then
        data.model = ent.AttachedEntity:GetModel()
    end
end)

hook.Add("PermaProps.PostSpawn", "PermaProps.343", function(ent, data)
    if ent:GetClass() == "prop_effect" then
        ent.AttachedEntity:SetModel(data.model)
    end
end)