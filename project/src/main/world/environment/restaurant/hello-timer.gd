extends Timer
## Manages creature greetings (hello, goodbye) and ensures they don't happen too frequently.

## Target number of creature greetings (hello, goodbye) per minute
const GREETINGS_PER_MINUTE := 3.0

## Number in the range [-1, 1] which corresponds to how many greetings we've given recently. If it's close to 1,
## we're very unlikely to receive a greeting. If it's close to -1, we're very likely to receive a greeting.
var greetiness := 0.0

## Creature who is about to say hello. We use a weak reference to avoid playing sound effects for creatures who
## leave the scene tree.
##
## Ref: (Creature) Creature who is about to say hello.
var _hello_customer_ref: WeakRef

func _process(delta: float) -> void:
	greetiness = clamp(greetiness + delta * GREETINGS_PER_MINUTE / 60, -1.0, 1.0)


## Returns 'true' if the creature should greet us. We calculate this based on how many times we've been greeted
## recently.
##
## Novice players or fast players won't mind receiving a lot of sounds related to combos because those sounds are
## associated with positive reinforcement (big combos), but they could get annoyed if creatures say hello/goodbye too
## frequently because those sounds are associated with negative reinforcement (broken combos).
func _should_chat() -> bool:
	var result := true
	if randf() <= greetiness:
		greetiness -= 1.0 / GREETINGS_PER_MINUTE
	else:
		result = false
	return result


## Conditionally schedules a 'hello!' voice sample for when a creature enters the restaurant.
##
## If there have been too many greetings recently, the 'hello!' voice sample is not scheduled.
func maybe_play_hello_voice(customer: Creature) -> void:
	if _should_chat():
		_hello_customer_ref = weakref(customer)
		start()


## Conditionally plays a 'check please!' voice sample for when a creature is ready to leave.
##
## If there have been too many greetings recently, the 'goodbye' voice sample is not played.
func maybe_play_goodbye_voice(customer: Creature) -> void:
	if _should_chat():
		customer.play_goodbye_voice()


func _on_timeout() -> void:
	var customer: Creature
	if _hello_customer_ref:
		customer = _hello_customer_ref.get_ref()
	if customer:
		customer.play_hello_voice()
		_hello_customer_ref = null
