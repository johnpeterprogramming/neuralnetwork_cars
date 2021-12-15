extends Node2D

var Car

export var population_size = 200
var selected
export var evolution_mode = true
var generation = 1


func _ready():
	Car = preload("res://Car.tscn")
	if evolution_mode:
		initial_population(population_size)

func initial_population(pop_size):
	for _i in range(pop_size):
		var carInstance = Car.instance()
		carInstance.hidden_layer = Layer.new(5, 6)
		carInstance.output_layer = Layer.new(6, 2)
		
		add_child(carInstance)
	for car in get_children():
		car.engine_on = true
		
func _input(event):
	if event.is_action_pressed("NextGen"):
		evolve()
	if event.is_action_pressed("SaveBest"):
		print("SAVING BEST CAR TO JSONFILE")
		var best_child
		var best_child_waypoints = 0
		for child in get_children():
			if child.total_waypoints_passed > best_child_waypoints:
				best_child_waypoints = child.total_waypoints_passed
				best_child = child
		var data = [best_child.hidden_layer.weights.duplicate(true), best_child.hidden_layer.biases.duplicate(true), best_child.output_layer.weights.duplicate(true), best_child.output_layer.biases.duplicate(true)]
		saveDictionary("res://bestCarAI.json", data)
	if event.is_action_pressed("loadBest"):
		print("LOADING BEST CAR FROM JSONFILE")
		var data = loadDictionary("res://bestCarAI.json")
		var carInstance = Car.instance()
		carInstance.hidden_layer = Layer.new(5, 6, false)
		carInstance.output_layer = Layer.new(6, 2, false)
		carInstance.hidden_layer.weights = data[0]
		carInstance.hidden_layer.biases = data[1]
		carInstance.output_layer.weights = data[2]
		carInstance.output_layer.biases = data[3]
		add_child(carInstance)
		carInstance.engine_on = true
		
		
func evolve():
	generation += 1
	print("GENERATION", generation)
	selected = select_by_fitness(10)

	var next_population = []
	if len(selected) > 0:
		#elitism only keeps best car to survive so prgress isnt lost
		next_population.append([selected[0].hidden_layer.weights.duplicate(true), selected[0].hidden_layer.biases.duplicate(true), selected[0].output_layer.weights.duplicate(true), selected[0].output_layer.biases.duplicate(true)])
		
		var j = 0
		while len(next_population) < population_size:
			var massive_output = crossover(selected[j%len(selected)], selected[(j+1)%len(selected)])
			var car1 = massive_output[0]
			var car2 = massive_output[1]
			next_population.append([car1[0].duplicate(true), car1[1].duplicate(true), car1[2].duplicate(true), car1[3].duplicate(true)])
			next_population.append([car2[0].duplicate(true), car2[1].duplicate(true), car2[2].duplicate(true), car2[3].duplicate(true)])
			j += 1
			
		for child in get_children():
			child.queue_free()

		for car in next_population:
			var carInstance = Car.instance()
			carInstance.hidden_layer = Layer.new(5, 6, false)
			carInstance.output_layer = Layer.new(6, 2, false)
			carInstance.hidden_layer.weights = car[0]
			carInstance.hidden_layer.biases = car[1]
			carInstance.output_layer.weights = car[2]
			carInstance.output_layer.biases = car[3]
			add_child(carInstance)

		for car in get_children():
			car.engine_on = true
	else:
		print('toggle evolution mode on SpawnPoint node')
		
func crossover(parent1, parent2):

	var par1_hidden = parent1.hidden_layer.weights
	var par2_hidden = parent2.hidden_layer.weights
	var par1_output = parent1.output_layer.weights
	var par2_output = parent2.output_layer.weights

	
	var par1_hidden_biases = parent1.hidden_layer.biases
	var par2_hidden_biases = parent2.hidden_layer.biases
	var par1_output_biases = parent1.output_layer.biases
	var par2_output_biases = parent2.output_layer.biases
	
	var hidden_inputs = len(par1_hidden[0])
	var hidden_n_neurons = len(par1_hidden)
	var output_inputs = len(par1_output[0])
	var output_n_neurons = len(par1_output)
	
	randomize()
	
#	Crossover
#	for i in range(hidden_n_neurons):
#		par1_hidden[i] = par1_hidden[i].slice(0, hidden_inputs/2) + par2_hidden[i].slice((hidden_inputs/2)+1, hidden_inputs, true)
#		par2_hidden[i] = par1_hidden[i].slice(0, hidden_inputs/2, true) + par2_hidden[i].slice((hidden_inputs/2)+1, hidden_inputs)
##		if randf() > mutation_rate:
#		par1_hidden[i][randi()%hidden_inputs] *= (randf()+0.5)
#		par2_hidden[i][randi()%hidden_inputs] *= (randf()+0.5)
#	for j in range(output_n_neurons):
#		par1_output[j] = par1_output[j].slice(0, output_inputs/2) + par2_output[j].slice((output_inputs/2)+1, output_inputs, true)
#		par2_output[j] = par1_output[j].slice(0, output_inputs/2, true) + par2_output[j].slice((output_inputs/2)+1, output_inputs)
##		if randf() > mutation_rate:
#		par1_output[j][randi()%output_inputs] *= (randf()+0.5)
#		par2_output[j][randi()%output_inputs] *= (randf()+0.5)
#
#	par1_hidden_biases = par1_hidden_biases.slice(0, hidden_inputs/2) + par2_hidden_biases.slice((hidden_inputs/2)+1, hidden_inputs, true)
#	par2_hidden_biases = par1_hidden_biases.slice(0, hidden_inputs/2, true) + par2_hidden_biases.slice((hidden_inputs/2)+1, hidden_inputs)
##	if randf() > mutation_rate:
#	par1_hidden_biases[randi()%hidden_inputs] *= (randf()+0.5)
#	par2_hidden_biases[randi()%hidden_inputs] *= (randf()+0.5)
#
#	par1_output_biases = par1_output_biases.slice(0, output_inputs/2) + par2_output_biases.slice((output_inputs/2)+1, output_inputs, true)
#	par2_output_biases = par1_output_biases.slice(0, output_inputs/2, true) + par2_output_biases.slice((output_inputs/2)+1, output_inputs)
##	if randf() > mutation_rate:
#	par1_output_biases[randi()%output_n_neurons] *= (randf()+0.5)
#	par2_output_biases[randi()%output_n_neurons] *= (randf()+0.5)
#
#	ONLY USING MUTATION BECAUSE FOR SOME REASON IT WORKS BETTER THAN CROSSOVER
	for i in range(hidden_n_neurons):
		par1_hidden[i][randi()%hidden_inputs] *= (randf()+0.5)
		par2_hidden[i][randi()%hidden_inputs] *= (randf()+0.5)
	for j in range(output_n_neurons):
		par1_output[j][randi()%output_inputs] *= (randf()+0.5)
		par2_output[j][randi()%output_inputs] *= (randf()+0.5)

	par1_hidden_biases[randi()%hidden_inputs] *= (randf()+0.5)
	par2_hidden_biases[randi()%hidden_inputs] *= (randf()+0.5)

	par1_output_biases[randi()%output_n_neurons] *= (randf()+0.5)
	par2_output_biases[randi()%output_n_neurons] *= (randf()+0.5)
	
	
	return [[par1_hidden, par1_hidden_biases, par1_output, par1_output_biases],
			[par2_hidden, par2_hidden_biases, par2_output, par2_output_biases]] 

func select_by_fitness(parent_pop_size):
	var selection_children = []

	var child_fitnesses = []
	var children = get_children()

	for child in get_children():
		child_fitnesses.append(child.total_waypoints_passed)

	for i in range(get_child_count()):
		selection_children.append(children[child_fitnesses.find(child_fitnesses.max(), 0)])
		children.erase(children[child_fitnesses.find(child_fitnesses.max(), 0)])
		child_fitnesses.erase(child_fitnesses.max())
	
	return selection_children.slice(0, parent_pop_size)

func loadDictionary(path):
	var file = File.new()
	file.open(path, File.READ)
	var theDict = parse_json(file.get_as_text())
	file.close()
	return theDict

func saveDictionary(path, dict):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(to_json(dict))
	file.close()
