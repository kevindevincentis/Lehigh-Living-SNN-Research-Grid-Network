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

h("objref outputCounts[grid.outputs.count()]")

threshold = 0
h('z = 0')
for i in range(int(h.grid.outputs.count())):
    h.z = i
    # outputs[i].record(h.nn.outCells[i].soma(0.5)._ref_v)
    h('grid.outputs.object(z).soma outputCounts[z] = new APCount(0.5)')
    h.outputCounts[i].thresh = threshold

outputs = [0] * int(h.grid.outputs.count())

results = [list() for i in range(10)]

trials = 1000
for cur in range(trials):
    print "Image %d" %cur

    img = images[cur]
    h('numInputs = 1')
    h.numInputs = len(img)
    h('double img[numInputs]')

    for i in range(len(img)):
        h.img[i] = img[i]

    h('grid.input(&img)')

    h('access grid.outputs.object(0).soma')


    h.tstop = 16
    h.run()

    for i in range(len(outputs)):
        outputs[i] = h.outputCounts[i].n

    results[labels[cur]].append(outputs)

# Save the results
results = {'results': results}
sio.savemat('cluster_data', results)

try:
    input('Exit by pressing a key')
except: SyntaxError
