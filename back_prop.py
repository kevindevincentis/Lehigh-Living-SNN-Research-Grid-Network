# Code adpated from https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/
import copy

def calc_weight_changes(outputs, truths, inputs, h):
    LEARNING_RATE = .001
    nWeights = 196
    err = calculate_total_error(outputs, truths)
    # print outputs
    return (train(outputs, truths, inputs, nWeights, LEARNING_RATE, h), err)

def train(outputs, truths, inputs, nWeights, LEARNING_RATE, h):
    nNeurons = len(outputs)
    pd_errors_wrt_output_neuron_total_net_input = [0] * nNeurons

    weightDetlas = [0] * nNeurons

    # Only modify weights of neurons which were wrong or should be strengthened
    modify = set()
    truths = list(truths)
    for i in range(nNeurons):
        if outputs[i] != truths[i]: modify.add(i)
    #
    print modify


    for o in range(nNeurons):
        # if (o in modify):
            pd_errors_wrt_output_neuron_total_net_input[o] = calculate_pd_error_wrt_total_net_input(truths[o], outputs[o])


    h('idx = 0')
    for o in range(nNeurons):
        temp = list()
        h.idx = o
        h('val = grid.outputs.object(idx).curSize')
        curSize = int(h.val)
        # if o in modify:
        for w_ho in range(curSize):
            idx = h.grid.outputs.object(o).idxList[w_ho]

            inp = inputs[idx]
            if (inp > 1.0/90): inp = 1
            else: inp = 0
            pd_error_wrt_weight = pd_errors_wrt_output_neuron_total_net_input[o] * inp

            temp.append(-LEARNING_RATE * pd_error_wrt_weight)
            if temp[len(temp) - 1] != 0: print temp[len(temp) - 1]
        # else: temp = [0] * curSize
        weightDetlas[o] = copy.copy(temp)

    return weightDetlas

def calculate_total_error(outputs, truths):
    total_error = 0
    for o in range(len(truths)):
        total_error += calculate_error(outputs[o], truths[o])
    return total_error/len(truths)

def calculate_pd_error_wrt_total_net_input(target_output, output):
    return calculate_pd_error_wrt_output(output, target_output) * calculate_pd_total_net_input_wrt_input(output);

# The error for each neuron is calculated by the Mean Square Error method:
def calculate_error(output, target_output):
    return 0.5 * (target_output - output) ** 2

def calculate_pd_error_wrt_output(output, target_output):
    return -(target_output - output)

def calculate_pd_total_net_input_wrt_input(output):
    return 1
