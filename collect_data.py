import scipy.io as sio
from neuron import h, gui
from matplotlib import pyplot
import copy

# Create the network
h('''load_file("grid_network.hoc")
objref grid
grid = new grid_network(500, 0.23, 304)''')

# Load images to give to the network
vals = sio.loadmat('../MNIST/training_values_compressed.mat')
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
trials = 1000
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
sio.savemat('cluster_data', results)

try:
    input('Exit by pressing a key')
except: SyntaxError
