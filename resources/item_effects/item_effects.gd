extends Resource
class_name ItemEffect

# Base effect contract: return true when effect execution succeeds.
func effect(context:EffectContext)->bool:
	return true
