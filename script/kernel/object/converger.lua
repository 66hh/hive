--converger.lua
local tinsert      = table.insert
local check_failed = hive.failed

local thread_mgr   = hive.get("thread_mgr")

local RPC_TIMEOUT  = hive.enum("NetwkTime", "DB_CALL_TIMEOUT")

local Converger    = class()
local prop         = property(Converger)
prop:reader("title", "")
prop:reader("executers", {})    --执行器列表

function Converger:__init(title)
    self.title = title
end

--添加执行器
-- executer失败返回 false, err
-- executer成功返回 true, code, data
function Converger:push(executer)
    tinsert(self.executers, executer)
end

--执行
function Converger:execute()
    local all_datas  = {}
    local count      = #self.executers
    local session_id = thread_mgr:build_session_id()
    for i, executer in ipairs(self.executers) do
        local success, corerr, data = true, 0
        thread_mgr:fork(function()
            success, corerr, data = executer()
            all_datas[i]          = data
            count                 = count - 1
            thread_mgr:try_response(session_id, success, corerr)
        end)
        local exec_failed, code = check_failed(corerr, success)
        if exec_failed then
            return false, code
        end
    end
    while count > 0 do
        local soc, corerr       = thread_mgr:yield(session_id, self.title, RPC_TIMEOUT)
        local exec_failed, code = check_failed(corerr, soc)
        if exec_failed then
            return false, code
        end
    end
    return true, all_datas
end

return Converger
