_G.threading = {}
local threads = {}
function threading.step()
    for id,thread in pairs(threads) do
        local pulledEvent = nil
        if thread.filter then
            pulledEvent = event.getFirst(thread.category or "All",thread.filter)
        else
            pulledEvent = event.getFirst(thread.category or "All")
        end
        if (not thread.awaitingEvent or pulledEvent) and thread.nextRun <= chip.getTime() then
            local success, proto, val1, val2 = coroutine.resume(thread.coroutine,table.unpack(pulledEvent or {}))
            if success and coroutine.status(thread.coroutine) ~= "dead" then
                if proto == "sleep" then
                    thread.nextRun = val1
                    thread.awaitingEvent = false
                elseif proto == "event" then
                    thread.filter = val1
                    thread.category = val2
                    thread.awaitingEvent = true
                end
            else
                printerror(proto)
                threads[id] = nil
            end
        end
    end
end

function threading.addThread(co)
    if type(co) == "function" then co = coroutine.create(co) end
    local thread = {coroutine=co,nextRun=chip.getTime()}
    local indx = 0
    while true do
        indx = indx + 1
        if threads[indx] == nil then
            threads[indx] = thread
            return indx
        end
    end
end

function _G.sleep(milis)
    coroutine.yield("sleep", chip.getTime() + milis)
    return true
end

function _G.waitTill(timestamp)
    coroutine.yield("sleep", timestamp)
end

function _G.awaitEvent(filter, category)
    return coroutine.yield("event", filter, category)
end