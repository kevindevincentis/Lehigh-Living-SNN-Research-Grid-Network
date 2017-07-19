import scipy.io as sio
from neuron import h, gui
from matplotlib import pyplot

h('''load_file("grid_network.hoc")
objref grid
grid = new grid_network(500, 0.23, 196)''')

# Load images to give to the network
vals = sio.loadmat('../MNIST/training_values_compressed.mat')
images = vals['images']
labels = vals['labels']
labels = labels[0]

cur = 4

# Input the image to the network
img = images[cur]
h('numInputs = 1')
h.numInputs = len(img)
h('double img[numInputs]')

for i in range(len(img)):
    h.img[i] = img[i]

h('grid.input(&img)')

inhibit = [1] * 304
h.numInputs = 304
h('double inh[numInputs]')
for i in range(len(inhibit)):
    h.inh[i] = inhibit[i]

h('grid.set_excitator(&inh)')

h('access grid.outputs.object(0).soma')

# Run the simulation
h.tstop = 50
h('xopen("output_sample.ses")')
h.run()

# Wait for input to exit to allow time for looking at output through GUI
try:
    input('Exit by pressing a key')
except: SyntaxError
