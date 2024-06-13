#This script reads a list of native contacts and determines the more frequent contacts in a trajectory
#Bugs can be reported to: apoma@ippt.pan.pl, fcofas@ippt.pan.pll, golivos@ippt.pan.pl

import pandas as pd
import matplotlib.pyplot as plt

# Read a native contact list
data = pd.read_csv('all_contacts.dat', sep=' ', header=None, names=['A', 'B'])

# Write here the number of frames
num_frames = 1000

# Calculate the frequency of each pair
pair_counts = data.groupby(['A', 'B']).size().reset_index(name='count')

# Set a cut-off frequency to find representative native contacts (70 %in this example)
significant_pairs = pair_counts[pair_counts['count'] >= 0.70 * num_frames]
significant_pairs['A'] = significant_pairs['A'].astype(str)
significant_pairs['B'] = significant_pairs['B'].astype(str)
significant_pairs['pair_label'] = significant_pairs['A'] + ' ' + significant_pairs['B']

# Save the native contacts list (by pairs) in a new *.itp file, without duplications
significant_pairs.to_csv('go_contacts_70.itp', columns=['A', 'B'], sep=' ', header=False, index=False)
