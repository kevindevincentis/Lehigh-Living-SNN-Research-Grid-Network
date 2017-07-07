import scipy.io as sio
from neuron import h, gui
from matplotlib import pyplot

h('''load_file("grid_network.hoc")
objref grid
grid = new grid_network(500, 0.23, 196)''')

print h.grid.outputs.count()

vals = sio.loadmat('../MNIST/training_values_compressed.mat')
images = vals['images']
labels = vals['labels']
labels = labels[0]

cur = 1

img = images[cur]
h('numInputs = 1')
h.numInputs = len(img)
h('double img[numInputs]')

for i in range(len(img)):
    h.img[i] = img[i]

h('grid.input(&img)')

h('access grid.outputs.object(0).soma')

h.tstop = 100
h.run()

try:
    input('Exit by pressing a key')
except: SyntaxError
