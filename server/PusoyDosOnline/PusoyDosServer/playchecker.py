def compare(play, pile):
	if len(play) != len(pile):
		return False
	for i in range(len(play)):
		if play[i] < pile[i]:
			return False
		elif play[i] > pile[i]:
			return True
	# If this stage is reached,
	# both arrays are the same!
	return False

def process(arr):
	ret = []

	# Empty arrays are invalid
	if len(arr) == 0:
		return [0]

	# Format of Single-element arrays
	# 1st value = length (1)
	# 2nd value = rank
	# 3rd value = suit
	if len(arr) == 1:
		ret.append(1)
		ret.append(arr[0] % 100)
		ret.append(arr[0] // 100)
		return ret

	# Format of 2-element arrays
	# 1st value = length (2)
	# 2nd value = rank
	# 3rd value = better suit
	if len(arr) == 2:
		# Check if they are indeed a pair:
		if (arr[0] % 100) != arr[1] % 100:
			ret.append(0)
			return ret

		ret.append(2)
		ret.append(arr[0] % 100)
		ret.append(max((arr[0] // 100),arr[1] // 100))
		return ret

	# Format of 3-element arrays
	# 1st value = length (3)
	# 2nd value = rank
	if len(arr) == 3:
		ranks = [i%100 for i in arr]
		if max(ranks) != min (ranks):
			ret.append[0]
			return ret

		ret.append(3)
		ret.append(ranks[0])
		return ret

	# 4-element arrays are invalid
	if len(arr) == 4:
		ret.append(0)
		return ret

	# Format of 5-element arrays
	# 1st value = length (5)
	# 2nd value = Type of hand (1 = straight, 5 = straight flush)
	# 3rd, 4th value represent highest card
	# 4th value may be a 0 (padding)
	if len(arr) == 5:
		ranksUnsorted = [i%100 for i in arr]
		suits = [i//100 for i in arr]
		ranks = sorted(ranksUnsorted)
		if ranks[0]+1 == ranks[1] and ranks[1] + 1 == ranks[2] \
			and ranks[2] + 1 == ranks[3] and ranks[3] + 1 == ranks[4]:
			if max(suits) == min(suits):
				# Is a straight flush
				ret.append(5)
				ret.append(5)
				ret.append(ranks[4])
				ret.append(suits[0])
				return ret
			else:
				# Is straight
				ret.append(5)
				ret.append(1)
				ret.append(ranks[4])
				for i in range(5):
					if arr[i]%100 == ranks[4]:
						ret.append(arr[i] // 100)
						return ret

		if max(suits) == min(suits):
			# Is flush
			ret.append(5)
			ret.append(2)
			ret.append(max(ranks))
			ret.append(suits[0])
			return ret

		if (ranks[0] == ranks[1] and ranks[1] == ranks[2] \
			and ranks[2] == ranks[3]) or (ranks[1] == ranks[2] and \
			ranks[2] == ranks[3] and ranks[3] == ranks[4]):
			# Is four of a kind
			ret.append(5)
			ret.append(4)
			ret.append(ranks[3])
			ret.append(0)
			return ret

		if (ranks[0] == ranks[1] and ranks[1] == ranks[2] and ranks[3] == ranks[4]) \
			or (ranks[0] == ranks[1] and ranks[2] == ranks[3] and ranks[3] == ranks[4]):
			# Is full house
			ret.append(5)
			ret.append(3)
			ret.append(ranks[2])
			ret.append(0)
			return ret

	return [0]