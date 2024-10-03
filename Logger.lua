--[[

Logger.lua
Author: oofman124 (GitHub)
Published: October 3, 2024
[BETA]

--]]

local RunService = game:GetService("RunService")
export type LogInstance = {
	Content : any,
	Type : "INFO" | "WARN" | "ERROR",
	Level : number,
}


local logger = {}
logger.__index = logger


function logger.new(name : string)
	local self = setmetatable({}, logger)
	
	self.Name = name
	self.Enabled = true
	self.PrintQueueEnabled = true
	self.Logs = {} :: {LogInstance}
	self.MaxLogs = 100
	self.PrintQueue = {} :: {LogInstance}
	self.MaxPrintQueue = 100
	self.DumpLevel = 1
	return self
end

function logger.demo()
	local newLogger = logger.new("DEMO")
	newLogger:Log({Content = "——Demo——", Type = "WARN", Level = 2024}, false)
	newLogger:Log({Content = "This is INFO ℹ️", Type = "INFO", Level = 2024}, false)
	newLogger:Log({Content = "This is WARN ⚠️", Type = "WARN", Level = 2024}, false)
	newLogger:Log({Content = "This is ERROR 🛑", Type = "ERROR", Level = 2024}, false)
	newLogger:Log({Content = "——End Of Demo——", Type = "WARN", Level = 2024}, false)
	task.wait()
	newLogger:DumpPrintQueue()
	
	newLogger:Dispose()
end


function logger:PrintLog(logInst : LogInstance)
	if self.Enabled then
		local strToFormat = "[%s — %s — %d]: %*"
		local formatted = string.format(strToFormat, self.Name, RunService:IsClient() and "CLIENT" or "SERVER", math.floor(logInst.Level), logInst.Content)
		task.defer(function()
			if logInst.Type == "INFO" then
				print(formatted)
			elseif logInst.Type == "WARN" then
				warn(formatted)
			elseif logInst.Type == "ERROR" then
				error(formatted)
			end
		end)
	end
end


function logger:DumpPrintQueue()
	if self.Enabled then
		for i,v in pairs(self.PrintQueue) do
			if v.Level >= self.DumpLevel then
				self:PrintLog(v)
			end
		end
		table.clear(self.PrintQueue)
	end
end

function logger:ClearEverything()
	if self.Enabled then
		table.clear(self.PrintQueue)
		table.clear(self.Logs)
	end
end


function logger:Log(log : LogInstance, dump : boolean?)
	if self.Enabled then
		table.insert(self.Logs, log)
		if #self.Logs > self.MaxLogs then
			table.remove(self.Logs, 1)
		end
		if self.PrintQueueEnabled then
			table.insert(self.PrintQueue, log)
			if #self.PrintQueue > self.MaxPrintQueue then
				table.remove(self.PrintQueue, 1)
			end
		end
		if dump == true or dump	== nil then
			self:PrintLog(log)
		end
	end
end

function logger:Dispose()
	self.Enabled = false
	table.clear(self)
	self = nil
end




return logger
