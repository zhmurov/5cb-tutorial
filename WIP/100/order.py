import MDAnalysis as mda

electric_field = input()

u = mda.Universe("conf.pdb", "md_iso_" + electric_field + ".xtc")
step = 0
order_params = []
times  = []
for ts in u.trajectory:
    box = ts.dimensions
    cosxi2 = 0.0
    ncosxi2 = 0
    ends1 = u.select_atoms("name N1")
    ends2 = u.select_atoms("name C19")
    for i in range(0, len(ends1) - 1):
        endi1 = ends1[i].position
        endi2 = ends2[i].position
        ri = endi2 - endi1
        ri[0] = ri[0] - round(ri[0] / box[0]) * box[0]
        ri[1] = ri[1] - round(ri[1] / box[1]) * box[1]
        ri[2] = ri[2] - round(ri[2] / box[2]) * box[2]
        ri_len = (ri[0]*ri[0] + ri[1]*ri[1] + ri[2]*ri[2]) ** 0.5
        for j in range(i + 1, len(ends1)):
            endj1 = ends1[j].position
            endj2 = ends2[j].position
            rj = endj2 - endj1
            rj[0] = rj[0] - round(rj[0] / box[0]) * box[0]
            rj[1] = rj[1] - round(rj[1] / box[1]) * box[1]
            rj[2] = rj[2] - round(rj[2] / box[2]) * box[2]
            rj_len = (rj[0]*rj[0] + rj[1]*rj[1] + rj[2]*rj[2]) ** 0.5
            cosxi = (ri[0]*rj[0] + ri[1]*rj[1] + ri[2]*rj[2]) / (ri_len * rj_len)
            cosxi2 += cosxi*cosxi
            ncosxi2 += 1
    cosxi2 /= ncosxi2
    order_param = (3.0*cosxi2 - 1.0)/2.0
    order_params.append(order_param)
    times.append(step)
    step += 1
    print(step, order_param)

import matplotlib.pyplot as plt
fig = plt.figure()
plt.plot(times, order_params)
plt.show()
fig.savefig("order_parameter_" + electric_field + ".png")