local Thread = {}

export type RBXThread = {
	Name: string,
	StepEvent: RBXScriptSignal,
	Connection: RBXScriptConnection,
	Completed: boolean,
	LastStepTime: number,
	Rate: number,
	Alive: boolean,
	StepFunction: (any) -> (),
}
Thread.Threads = {} :: {RBXThread}

function Thread.CreateThread(Name: string, Rate: number, StepEvent: RBXScriptSignal, StepFunction: (number) -> ()): RBXThread
	local self = {} :: RBXThread
	self.Name = Name
	self.StepEvent = StepEvent
	self.Completed = true
	self.Rate = Rate
	self.Alive = true
	self.LastStepTime = time()
	self.StepFunction = StepFunction
	self.Connection = StepEvent:Connect(function(...)
		if self.Completed and self.Alive and time()-self.LastStepTime >= 1/self.Rate then
			self.Completed = false
			self.StepFunction(...) 
			self.Completed = true
		end
	end)
	table.insert(Thread.Threads, self)
	return self
end

function Thread.FindThread(Name: string): RBXThread?
	for _, Thread in pairs(Thread.Threads) do
		if Thread.Name == Name then
			return Thread
		end
	end
	return nil
end

function Thread.RemoveThread(Name: string)
	for Index, Thread in pairs(Thread.Threads) do
		if Thread.Name == Name then
			Thread.Alive = false
			if Thread.Connection then
				Thread.Connection:Disconnect()
			end
			table.clear(Thread)
			table.remove(Thread.Threads, Index)
		end
	end
end

function Thread.RemoveDeadThreads()
	for Index, Thread in pairs(Thread.Threads) do
		if not Thread.Alive then
			if Thread.Connection then
				Thread.Connection:Disconnect()
			end
			table.clear(Thread)
			table.remove(Thread.Threads, Index)
		end
	end
end

return Thread

