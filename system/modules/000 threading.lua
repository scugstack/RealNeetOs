_G.threading = {}
local threads = {}
function threading.step()
    local pulled = {}
    for id,thread in pairs(threads) do
        local pulledEvent =  pulled[thread.filter or 1]
        if thread.filter then
            pulledEvent = event.getFirst(thread.category or "All",thread.filter)
            pulled[thread.filter] = pulledEvent
        else
            pulledEvent = event.getFirst(thread.category or "All")
            pulled[1] = pulledEvent
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
            return {PID = indx,isAlive = function () return co and coroutine.status(co) ~= "dead" end,kill = function () if co and coroutine.status(co) ~= "dead" then threading.kill(indx) end end}
        end
    end
end

function threading.blockOnThreads(...)
    local threads = {...}
    local PIDs = {}
    for _,thread in ipairs(threads) do
        PIDs[#PIDs+1] = threading.addThread(thread)
    end
    while true do
        local can_end = true
        for _,PID in ipairs(PIDs) do
            if threading.isAlive(PID) then
                can_end = false
            end
        end
        if can_end then
            return
        end
    end
end

function threading.isAlive(PID)
    return PID.isAlive()
end

function threading.kill(PID)
    threads[PID.PID] = nil
end

function _G.sleep(milis)
    coroutine.yield("sleep", chip.getTime() + (milis or 0))
    return true
end

function _G.waitTill(timestamp)
    coroutine.yield("sleep", timestamp)
end

function _G.awaitEvent(filter, category)
    return coroutine.yield("event", filter, category)
end