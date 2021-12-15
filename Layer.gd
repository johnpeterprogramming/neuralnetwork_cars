class_name Layer

var weights = []
var biases = []

func _init(n_inputs, n_neurons, random=true):
	if random:
		randomize()
		for _n in range(n_neurons):
			biases.append((randf()*2-1)/10)#behoort tussen -0.1 en 0.1 te wees

			var weight = []
			for _i in range(n_inputs):
				weight.append(randf()*2-1)#behoort tussen -1 en 1 te wees
			weights.append(weight)
		
func forward(input_layer):
	var output = []
	for x in range(len(weights)):#6
		var value = 0
		for y in range(len(input_layer)):#5
			value += input_layer[y] * weights[x][y]
		value += biases[x]
		value = max(0, value) #reLU activation
		output.append(value)
	return output
