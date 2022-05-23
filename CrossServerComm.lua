local MessagingService = game:GetService('MessagingService');
local HttpService = game:GetService('HttpService');

local MAIN_CHANNEL = 'CSC';
local REPLY_CHANNEL = 'CSC_R'
local REPLY_TIMEOUT = 5;

local CrossServerComm = {};

function CrossServerComm.On(event, callback)
	local connection;
	connection = MessagingService:SubscribeAsync(MAIN_CHANNEL .. event, function(msg)
		callback(table.unpack(msg.Data));
	end);

	return {
		Disconnect = function()
			connection:Disconnect();
		end,
	};
end;

function CrossServerComm.ReplyOn(event, callback)
	MessagingService:SubscribeAsync(REPLY_CHANNEL .. event, function(msg)
		local data = msg.Data;
		local id = data[1];
		table.remove(data, 1);

		CrossServerComm.Emit(REPLY_CHANNEL .. id .. event, callback(table.unpack(data)));
	end);
end;

function CrossServerComm.Emit(event, ...)
	MessagingService:PublishAsync(MAIN_CHANNEL .. event, {...});
end;

function CrossServerComm.EmitWithReply(event, ...)
	local id = HttpService:GenerateGUID(true);

	local res;
	local connection;
	connection = CrossServerComm.On(REPLY_CHANNEL .. id .. event, function(data)
		connection:Disconnect();
		connection = nil;

		res = data;
	end);

	local data = {...};
	table.insert(data, 1, id);
	MessagingService:PublishAsync(REPLY_CHANNEL .. event, data);

	local startTime = os.time();

	repeat
		if os.time() - startTime > REPLY_TIMEOUT then
			break;
		end;
		task.wait(0.2);
	until res;

	return res;
end;

return CrossServerComm;
