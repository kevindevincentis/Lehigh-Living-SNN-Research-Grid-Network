# Kevin DeVincentis
# Testing platform for using and understanding output of the grid_network
import scipy.io as sio
from neuron import h, gui
from matplotlib import pyplot
import sys

weightType = sys.argv[1]
cur = int(sys.argv[2])


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

    print weights[labels[cur]]

# Load images to give to the network
vals = sio.loadmat('../MNIST/training_values_compressed.mat')
images = vals['images']
labels = vals['labels']
labels = labels[0]

data = sio.loadmat('full_conn_centers.mat')
centers = data['bestCenters']

h("objref outputCounts[grid.outputs.count()]")


threshold = 0
h('z = 0')
for i in range(int(h.grid.outputs.count())):
    h.z = i
    h('grid.outputs.object(z).soma outputCounts[z] = new APCount(0.5)')
    h.outputCounts[i].thresh = threshold

outputs = [0] * int(h.grid.outputs.count())


# Input the image to the network
img = images[cur]
h('numInputs = 1')
h.numInputs = len(img)
h('double img[numInputs]')

for i in range(len(img)):
    h.img[i] = img[i]

h('grid.input(&img)')

# inhibit = [1] * 304
# h.numInputs = 304
# h('double inh[numInputs]')
# for i in range(len(inhibit)):
#     h.inh[i] = inhibit[i]
#
# h('grid.set_excitator(&inh)')

h('access grid.outputs.object(0).soma')

# Run the simulation
h.tstop = 16
# h('xopen("output_sample.ses")')
h.run()

# Obtain output
for i in range(len(outputs)):
    outputs[i] = h.outputCounts[i].n

print outputs
print centers[labels[cur]]
counter = 0
total = 0
for d in outputs:
    if d != centers[labels[cur]][counter]:
        total += 1
    counter += 1

print total

# Wait for input to exit to allow time for looking at output through GUI
try:
    input('Exit by pressing a key')
except: SyntaxError
