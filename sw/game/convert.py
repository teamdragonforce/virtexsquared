def elab(measures):
	notes = []
	for measure in measures:
		notetype = 16 / (len(measure) / 4)
		while len(measure):
			left = measure[0] == '1'
			up = measure[1] == '1'
			down = measure[2] == '1'
			right = measure[3] == '1'
			note = (left << 3) | (up << 2) | (down << 1) | right
			notes.append(note)
			for i in range(notetype - 1):
				notes.append(0)
			measure = measure[4:]
	return notes

from sys import stdin,stdout

lines = stdin.readlines()
lines = map ((lambda x: x.rstrip()), lines)
foo = ''.join(lines)
measures = foo.split(',')
ours = elab(measures)

for n in ours:
	stdout.write(chr(n))
