# Kevin DeVincentis
# Trains a grid_network using back-propagation
import scipy.io as sio
from neuron import h, gui
from matplotlib import pyplot
from back_prop import calc_weight_changes
import sys

setSize = int(sys.argv[1])
def updateNeurons(h, updates, weightVals):
    h('k = 0')
    for i in range(len(updates)):
        h.k = i
        h('size = grid.outputs.object(k).curSize')
        h('double update[size]')

        for j in range(int(h.size)):
            weightVals[i][j] += updates[i][j]
            h.update[j] = weightVals[i][j]
        h('grid.outputs.object(k).setInputWeights(&update)')

# Create the network
netSize = 500
inputSize = 196
h('netSize = 0')
h('inputSize = 0')
h.netSize = netSize
h.inputSize = inputSize
outputSize = netSize - inputSize
h('''load_file("grid_network.hoc")
objref grid
grid = new grid_network(netSize, 0.23, inputSize)''')

# Load images to give to the network
vals = sio.loadmat('../MNIST/training_values_compressed.mat')
images = vals['images']
labels = vals['labels']
labels = labels[0]

# Load cluster centers
data = sio.loadmat('basic_cluster_results_ham.mat')
centers = data['bestCenters']
print centers

# Set up counting objects for spike detection
h("objref outputCounts[grid.outputs.count()]")

threshold = 0
h('z = 0')
for i in range(int(h.grid.outputs.count())):
    h.z = i
    h('grid.outputs.object(z).soma outputCounts[z] = new APCount(0.5)')
    h.outputCounts[i].thresh = threshold

outputs = [0] * int(h.grid.outputs.count())

# Set up variable to store the weights of the neurons
weights = [0] * outputSize
for i in range(outputSize):
    weights[i] = list(h.grid.outputs.object(i).getInputWeights())


# Run the simulation many times to collect data points
for cur in range(setSize):
    Iter = 0
    err = 1
    lastErr = 0
    while (abs(err - lastErr) > .01):
        lastErr = err
        print "Image %d, Iter: %d" %(cur, Iter)

        # Input the image
        img = images[cur]
        h('numInputs = 1')
        h.numInputs = len(img)
        h('double img[numInputs]')

        for i in range(len(img)):
            h.img[i] = img[i]

        h('grid.input(&img)')

        h('access grid.outputs.object(0).soma')

        # Run simulation
        h.tstop = 16
        h.run()

        # Obtain output and update results
        for i in range(len(outputs)):
            outputs[i] = h.outputCounts[i].n

        (updates, err) = calc_weight_changes(outputs, centers[labels[cur]], img, h)

        # Update the weights of the network
        updateNeurons(h, updates, weights)
        print err
        Iter += 1

# Save the results
# 2D matrix to store the trained weights
allWeights = [0] * outputSize
for i in range(outputSize):
    allWeights[i] = list(h.grid.outputs.object(i).getInputWeights())

# pyplot.show()

# Save the results
allWeights = {'allWeights': allWeights}
sio.savemat('trained_weights', allWeights)

try:
    input('Exit by pressing a key')
except: SyntaxError
