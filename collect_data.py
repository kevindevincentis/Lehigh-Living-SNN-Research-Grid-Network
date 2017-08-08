# Kevin DeVincentis
# Collects the output of a neural network after inputting images
# The output is stored as follows: 3D list where...
# 1st D is digit, 2nd D is output vector, 3rd D is value in a vector
# User inputs the source of the input images and if the network has been trained
import scipy.io as sio
from neuron import h, gui
from matplotlib import pyplot
import copy
import sys

# Obtain the type of weights (trained or random) from the command line
weightType = sys.argv[1]
imgSource = sys.argv[2]

# Create the network
h('''load_file("grid_network.hoc")
objref grid
grid = new grid_network(500, 0.23, 196)''')

if (weightType.lower() == "trained"):
    weights = sio.loadmat('./trained_weights.mat')
    weights = weights['allWeights']
    weights = weights[0]
    h('k = 0')

    for i in range(len(weights)):
        h.k = i

        h('size = grid.outputs.object(k).curSize')
        h('double update[size]')
        for j in range(int(h.size)):
            h.update[j] = weights[i][0][j]
        h('grid.outputs.object(k).setInputWeights(&update)')

# Load images to give to the network
vals = sio.loadmat(imgSource)
images = vals['images']
labels = vals['labels']
labels = labels[0]

# Set up counting objects for spike detection
h("objref outputCounts[grid.outputs.count()]")

threshold = 0
h('z = 0')
for i in range(int(h.grid.outputs.count())):
    h.z = i
    h('grid.outputs.object(z).soma outputCounts[z] = new APCount(0.5)')
    h.outputCounts[i].thresh = threshold

outputs = [0] * int(h.grid.outputs.count())

results = [list() for i in range(10)] # Variable to save data

# Run the simulation many times to collect data points
trials = 10000
for cur in range(trials):
    print "Image %d" %cur

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

    results[labels[cur]].append(copy.copy(outputs))

# Save the results
results = {'results': results}
if (weightType.lower() == "trained"):
    sio.savemat('no_kmeans_trained_cluster_data', results)
else: sio.savemat('large_cluster_data', results)

try:
    input('Exit by pressing a key')
except: SyntaxError
