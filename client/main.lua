RSGCore = exports['rsg-core']:GetCoreObject()
local cash, bank

local function Toggle(state)
    SendNUIMessage({
        message = 'toggle',
        value = state
    })
end

local function UpdateAccounts(accounts)
    if accounts == nil then return end

    local tempCash, tempBank

    for account, amount in pairs(accounts) do
        if account == 'bank' then
            tempBank = amount
        elseif account == 'cash' then
            tempCash = amount
        end
    end

    return tempCash, tempBank
end

local function MainThread()
    Toggle(true)

    CreateThread(function()
        local playerServerId = GetPlayerServerId(PlayerId())

        while true do
            local PlayerData = RSGCore.Functions.GetPlayerData()

            SendNUIMessage({
                message = 'info',
                value = {
                    bank = ("$" .. bank),
                    money = ("$" .. cash),
                    job = string.upper(PlayerData.job.label),
                    grade = string.upper(PlayerData.job.grade.name),
                    id = string.upper("ID " .. playerServerId)
                }
            })

            Wait(500)
        end
    end)
end

AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    local PlayerData = RSGCore.Functions.GetPlayerData()
    cash, bank = UpdateAccounts(PlayerData.money)
    MainThread()
end)

AddEventHandler('RSGCore:Client:OnPlayerUnload', function()
    Toggle(false)
end)

AddEventHandler('RSGCore:Client:OnPauseMenuActive', function(state)
    Toggle(not state)
end)

RegisterNetEvent('RSGCore:Player:SetMoney', function(account, amount)
    if account == 'cash' then
        cash = amount
    elseif account == 'bank' then
        bank = amount
    end
end)

RegisterNetEvent('RSGCore:Player:SetJob', function(job)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    PlayerData.job = job
end)


------------------------------------------------
-- on money change
------------------------------------------------
RegisterNetEvent('hud:client:OnMoneyChange', function()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        cash = PlayerData.money.cash
        bank = PlayerData.money.bank
    end)
    local PlayerData = RSGCore.Functions.GetPlayerData()

    SendNUIMessage({
        message = 'info',
        value = {
            bank = ("$" .. bank),
            money = ("$" .. cash),
            job = string.upper(PlayerData.job.label),
            grade = string.upper(PlayerData.job.grade.name),
            id = string.upper("ID " .. GetPlayerServerId(PlayerId()))
        }
    })
end)



AddEventHandler('onResourceStart', function(resName)
    if GetCurrentResourceName() ~= resName then return end
    Wait(1000)
    local PlayerData = RSGCore.Functions.GetPlayerData()
    cash, bank = UpdateAccounts(PlayerData.money)
    MainThread()
end)
