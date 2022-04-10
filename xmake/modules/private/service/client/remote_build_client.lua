--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        remote_build_client.lua
--

-- imports
import("core.base.socket")
import("private.service.config")
import("private.service.message")
import("private.service.client.client")
import("private.service.socket_stream")

-- define module
local remote_build_client = remote_build_client or client()
local super = remote_build_client:class()

-- init client
function remote_build_client:init()
    super.init(self)
end

-- get class
function remote_build_client:class()
    return remote_build_client
end

-- connect to the remote server
function remote_build_client:connect(addr, port)
    local statusfile = self:statusfile()
    local sock = socket.connect(addr, port)
    local connected = false
    print("%s: connect %s:%d ..", self, addr, port)
    if sock then
        local stream = socket_stream(sock)
        if stream:send_msg(message.new_ping()) and stream:flush() then
            local msg = stream:recv_msg()
            if msg then
                vprint(msg:body())
                connected = true
            end
        end
    end
    if connected then
        print("%s: connected!", client)
        io.save(statusfile, {addr = addr, port = port})
    else
        print("%s: connect %s:%d failed", self, addr, port)
        os.tryrm(statusfile)
    end
end

-- disconnect server
function remote_build_client:disconnect()
    local statusfile = self:statusfile()
    if os.isfile(statusfile) then
        os.rm(statusfile)
        print("%s: disconnected!", self)
    else
        print("%s: has been disconnected!", self)
    end
end

-- is connected?
function remote_build_client:is_connected()
    return os.isfile(self:statusfile())
end

-- get the status
function remote_build_client:status()
    local status = self._STATUS
    local statusfile = self:statusfile()
    if not status and os.isfile(statusfile) then
        status = io.load(statusfile)
        self._STATUS = status
    end
    return status
end

-- get the status file
function remote_build_client:statusfile()
    return path.join(self:workdir(), "status.txt")
end

function remote_build_client:__tostring()
    return "<remote_build_client>"
end

function main()
    local instance = remote_build_client()
    instance:init()
    return instance
end
