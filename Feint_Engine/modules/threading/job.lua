local job = {}

local private = {}

local jobs = {}
local numJobs = 0

function private.scheduleJob(func)
	numJobs = numJobs + 1
	jobs[numJobs] = {func = func}
end

function private.runJobs()
	for i = 1, numJobs, 1 do

	end
end

setmetatable(job, {
	__index = private,
})

return job
