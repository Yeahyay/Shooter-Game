local job = {}

local ffi = require("ffi") -- luacheck: ignore

function job:newFor(id, archetypeChunk, rangeMin, rangeMax, arguments, jobData, operation)
	assert(operation and type(operation) == "function", "no operation given", 3)
	local job = {
		jobType							= "for";
		jobID								= id;
		jobData							= jobData and string.dump(jobData) or nil;
		jobOperation					= string.dump(operation);

		jobRangeMin						= rangeMin or 0;
		jobRangeMax						= rangeMax or archetypeChunk.numEntities - 1;

		entityByteData					= archetypeChunk.byteData;
		entityIndexToId				= archetypeChunk.entityIndexToId;

		archetypeStructDefinition	= archetypeChunk.structDefinition;
		archetypeString				= archetypeChunk.archetype.archetypeString;
		archetypeChunkIndex			= archetypeChunk.index;
		archetypeChunksize			= archetypeChunk.numEntities;
		archetypeChunkCapacity		= archetypeChunk.capacity;
	}
	return job
end

function job:new(id, jobData, operation)
	local job = {
		jobType			= "generic";
		jobID				= id;
		jobData			= jobData and string.dump(jobData) or nil;
		jobOperation	= string.dump(operation);
	}
	return job
end

return job
