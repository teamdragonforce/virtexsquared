from sys import stderr

def find_info(lines):
	offset = 0
	bpm = 0
	while len(lines):
		line = lines[0]
		lines = lines[1:]
		fields = line.lstrip("#").rstrip(";").split(":")
		if fields[0] == "OFFSET":
			offset = fields[1]
		if fields[0] == "BPMS":
			bpms = fields[1].split("=")
			bpm = bpms[1]
			if len(bpms) > 2:
				stderr.write("error: bpm change detected (not supported)!\n")
		if fields[0] == "NOTES":
			break
	rest = ''.join(lines)
	stepsets = rest.split(';')
	firstset_sections = stepsets[0].split(':')
	steps = firstset_sections[5]
	return (bpm, offset, steps)

def is_step(c):
	return c == '1' or c == '2' or c == '3'

def elab(stepdata):
	measures = stepdata.split(',')
	notes = []
	for measure in measures:
		notetype = 16 / (len(measure) / 4)
		while len(measure):
			left = is_step(measure[0])
			up = is_step(measure[1])
			down = is_step(measure[2])
			right = is_step(measure[3])
			note = (left << 3) | (up << 2) | (down << 1) | right
			note = note | (note << 4)
			notes.append(note)
			for i in range(notetype - 1):
				notes.append(0)
			measure = measure[4:]
	return notes

def write_int(f, n):
	f.write(chr((n>>0)&0xff))
	f.write(chr((n>>8)&0xff))
	f.write(chr((n>>16)&0xff))
	f.write(chr((n>>24)&0xff))

from sys import stdin,stdout
import re

stripcomment = re.compile("//.*")

lines = stdin.readlines()
lines = map ((lambda x: stripcomment.sub("", x)), lines)
lines = map ((lambda x: x.rstrip()), lines)

(bpm, offset, stepdata) = find_info(lines)

ours = elab(stepdata)

n_qbeats = len(ours)
samps_per_qbeat = int(48000 / (float(bpm) * 4 / 60))
offset_samps = int(float(offset)*48000)

stderr.write(str(bpm)+"\n")
stderr.write(str(offset)+"\n")
stderr.write(str(n_qbeats)+"\n")
stderr.write(str(samps_per_qbeat)+"\n")
stderr.write(str(offset_samps)+"\n")

write_int(stdout, n_qbeats)
write_int(stdout, samps_per_qbeat)
write_int(stdout, offset_samps)

for n in ours:
	stdout.write(chr(n))
