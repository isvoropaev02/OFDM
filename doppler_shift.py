import numpy as np
import matplotlib.pyplot as plt

freq = np.arange(-6, 6.1, 0.1)
shift_coef = 0.2
prop_cycle = plt.rcParams['axes.prop_cycle']
colors = prop_cycle.by_key()['color']

fig1 = plt.figure(figsize=(8,5))
ax_1 = fig1.add_subplot(111)
for carrier in range(-3, 4, 1):
    ax_1.plot(freq, np.sinc(freq-carrier))
ax_1.set_ylabel("Absolute value")
ax_1.set_xlabel("Frequency")
ax_1.set_xticks(np.arange(-6, 7, 1))
ax_1.grid()
ax_1.set_title('Spectrum without Doppler shift')
plt.show()


fig2 = plt.figure(figsize=(8,5))
ax_1 = fig2.add_subplot(111)
for carrier in range(0, 4, 1):
    shift = shift_coef#*np.abs(carrier)
    ax_1.plot(freq, np.sinc(freq-carrier), linestyle="--", color=colors[carrier])
    ax_1.plot(freq, np.sinc(freq-carrier-shift), color=colors[carrier])
ax_1.set_ylabel("Absolute value")
ax_1.set_xlabel("Frequency")
ax_1.set_xticks(np.arange(-6, 7, 1))
ax_1.grid()
ax_1.set_title('Spectrum with Doppler shift')
plt.show()