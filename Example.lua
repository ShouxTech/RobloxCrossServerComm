local CrossServerComm = require(script.Parent:WaitForChild('CrossServerComm'));

-- Example 1:

CrossServerComm.On('add', function(operand1, operand2)
	print(operand1 + operand2);
end);

CrossServerComm.Emit('add', 1, 2);

-- Example 2:

CrossServerComm.ReplyOn('requestAdd', function(operand1, operand2)
	return operand1 + operand2;
end);

print(CrossServerComm.EmitWithReply('requestAdd', 1, 2));
