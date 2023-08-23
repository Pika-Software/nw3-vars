install( "packages/net-messager.lua", "https://raw.githubusercontent.com/Pika-Software/net-messager/main/lua/packages/net-messager.lua" )
install( "packages/glua-extensions", "https://github.com/Pika-Software/glua-extensions" )

local hook = hook

local messager = _G._NW3
if type( messager ) ~= "table" then
    messager = net.Messager( gpm.Package:GetIdentifier() )
    _G._NW3 = messager
end

local ENTITY = FindMetaTable( "Entity" )

function ENTITY:InitNW3Var()
    return messager:CreateSync( self )
end

if CLIENT then

    hook.Add( "NetworkEntityCreated", "Synchronization", function( entity )
        hook.Run( "NW3EntityInitialized", entity, entity:InitNW3Var() )
    end )

end

function ENTITY:GetNW3VarTable()
    local sync = self:InitNW3Var()
    if not sync then return end
    return sync:GetTable()
end

function ENTITY:GetNW3Var( key, default )
    local sync = self:InitNW3Var()
    if not sync then return end
    return sync:Get( key, default )
end

function ENTITY:SetNW3Var( key, value )
    local sync = self:InitNW3Var()
    if not sync then return end
    sync:Set( key, value )
end

function ENTITY:SetNW3VarProxy( func, name )
    local sync = self:InitNW3Var()
    if not sync then return end
    sync:SetCallback( name or "Default", func )
end

if SERVER then

    hook.Add( "PlayerInitialized", "Synchronization", function( ply )
        messager:Sync( ply )
    end )

    local function remove( ent )
        local sync = messager:GetSync( ent )
        if not sync then return end
        sync:Destroy()
    end

    hook.Add( "PlayerDisconnected", "Destroying", remove )
    hook.Add( "EntityRemoved", "Destroying", remove )

end