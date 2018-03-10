# -*- coding: utf-8 -*-
"""
Created on Fri Mar  9 23:01:20 2018


@author: amit
"""

import basisgeneration as bg
import progbar as pb
import numpy as np
import matplotlib.pyplot as plt

N = 4
n = 4

p = 0

U = 8

eta = 0.1

spin = (0.5 * n) % 1

t = 1

#startpoint = -6
#stoppoint = 6

print("\033c", end = '')

if (n == 1):
    fs = "fermion"
else:
    fs = "fermions"

print("Calculating for", N, "sites with", n, fs, "and Sz =", spin)

waitmessagelist = [
                "this may take a while...",
                "please wait while this finishes...",
                "this will be done in a moment...",
                "this may take some time...",
                "this will take some time..."
                ]

waitmsg = np.random.choice(waitmessagelist)

print("Generating the basis...", waitmsg, sep = '')

basis = bg.createbasis(N, n, spin)

I = complex(0, 1)

if (len(basis) == 1):
    statesm = "state."
else:
    statesm = "state."

#print("The basis has", len(basis), statesm)
#
#i = 0
#for s in basis:
#    print(i, s.getstate())
#    i += 1

H = []

print("Generating the Hamiltonian...")

for s1 in basis:
    for s2 in basis:

        ta = 0
        for sigma in [-1, +1]:
            for i in range(0, N-1):
                s2a = bg.clonestate(s2)
                s2a.move(i, i+1, sigma)
                ta += bg.innerproduct(s1, s2a)

        tb = 0
        for sigma in [-1, +1]:
            for i in range(0, N-1):
                s2b = bg.clonestate(s2)
                s2b.move(i+1, i, sigma)
                ta += bg.innerproduct(s1, s2b)

        term = t * (ta + tb)

        H.append(term)

        i = len(H)
        pb.progressbar(i, 0, pow(len(basis),2))

H = np.array(H, dtype = np.complex)

H = np.reshape(H, ( len(basis), len(basis) ) )

for i in range(len(basis)):
    a = basis[i]
    particles = np.array(a.upconfig) + np.array(a.downconfig)
    for nump in particles:
        if (nump == 2):
            H[i][i] += U

#print(H)
print('')

def z(omega):
    return omega + I * eta

def G(omega):
    return np.linalg.inv(z(omega) \
    * np.eye(len(basis), dtype = np.complex) - H)

#p = input("Enter the state number to calculate the spectral weight for: ")
p = int(p)


ev = np.linalg.eigvalsh(H)
startpoint = np.floor(min(ev)) - 3
stoppoint = np.ceil(max(ev)) + 3

#print("\nThe eigenvalues of the Hamiltonian are:")
#for e in ev:
#    print( round(e, 2), sep = '\t', end = ' ' )
#
#print('')

w_list = np.linspace(startpoint, stoppoint, 2000)

#print("Generating local spectral weight function for state:\n", \
#        basis[p].getstate() )
#
#A_list = []
#i = 0
#for w in w_list:
#    A_list.append( -(1/np.pi) * np.imag( G(w)[p][p] ) )
#    pb.progressbar(i, 0, len(w_list) - 1)
#    i += 1
#
#plt.plot(w_list, A_list)
#plt.title( "Local spectral weight function for the state " +\
#             str(p) )
#plt.show()
#
#print('')

print("Generating density of states...")

i = 0
Ap_list = []
for w in w_list:
    Ap_list.append( (1/len(basis)) * (-1/np.pi) * np.imag( np.trace(G(w)) ) )

    pb.progressbar(i, 0, len(w_list) - 1)
    i += 1

plt.plot(w_list, Ap_list)
plt.title(
        "DOS for " + str(N) + " sites with " + str(n) \
            + " " + fs + ", Sz = " + str(spin) + ", U = " + str(U)
        )

plt.savefig(
            str(N) + "_" + str(n) + "_" + str(int(spin*10)) +\
            "_" + str(U) + ".pdf")

plt.show()

print('')