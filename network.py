import scipy.io as sio
from neuron import h, gui
from matplotlib import pyplot

h('''load_file("grid_network.hoc")
objref grid
grid = new grid_network(100, 0)''')

try:
    input('Exit by pressing a key')
except: SyntaxError
