class_name CallQueue
## Queue of deferred method calls, for scenarios where we need to call methods in the future.
##
## A typical use case scenario for this queue involves three steps:
## 	1. Repeatedly deferring methods using defer(). This schedules calls to occur in the future.
## 	2. Repeatedly popping deferred calls using pop_deferred().
## 	3. Verifying the queue is empty using assert_empty().

## List of Dictionary items defining method calls and arguments.
## 	'target': (String) object whose method should be called
## 	'method': (String) method to call
## 	'args': (Array) arguments to pass into the method
var _deferred_calls := []

## Add a method call to the queue.
##
## Parameters:
## 	'target': the object whose method should be called
##
## 	'method': the method to call
##
## 	'args': arguments to pass into the method
func defer(target: Object, method: String, args: Array) -> void:
	_deferred_calls.append({"target": target, "method": method, "args": args})


## Pops method call from the queue, calling the appropriate target.
##
## Parameters:
## 	'target': (Optional) object whose calls should be dequeued. If unspecified, method calls will be dequeued
## 		for all objects.
##
## 	'method': (Optional) method name whose calls which should be dequeued. If unspecified, method calls will be
## 		dequeued for all method names.
func pop_deferred(target: Object = null, method: String = "") -> void:
	var new_deferred_calls := []
	
	for call in _deferred_calls:
		if (target and call.target != target) or (method and call.method != method):
			new_deferred_calls.append(call)
		else:
			target.callv(method, call.args)
	
	_deferred_calls = new_deferred_calls


## Pushes a warning message if the queue is not empty.
##
## This should be called after calling pop_deferred() to ensure all calls were dequeued.
func assert_empty() -> void:
	if not _deferred_calls.empty():
		push_warning("CallQueue should be empty, but was: %s" % [_deferred_calls])
