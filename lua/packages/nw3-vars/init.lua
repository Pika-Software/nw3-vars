import( gpm.LuaPackageExists( "packages/glua-extensions" ) and "packages/glua-extensions" or "https://raw.githubusercontent.com/Pika-Software/glua-extensions/main/package.json" )
import( gpm.LuaPackageExists( "packages/net-messager" ) and "packages/net-messager" or "https://raw.githubusercontent.com/Pika-Software/net-messager/main/package.json" )

local packageName = gpm.Package:GetIdentifier()
local messager = net.Messager( packageName )
local ENTITY = FindMetaTable( "Entity" )

function ENTITY:InitNW3Var()
    return messager:CreateSync( self )
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

    hook.Add( "PlayerInitialized", packageName, function( ply )
        messager:Sync( ply )
    end )

    local function remove( ent )
        local sync = messager:GetSync( ent )
        if not sync then return end
        sync:Destroy()
    end

    hook.Add( "PlayerDisconnected", packageName, remove )
    hook.Add( "EntityRemoved", packageName, remove )

end
