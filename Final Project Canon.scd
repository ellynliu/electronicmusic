// Ellyn Liu
// Electronic Music II Final Project
// Canon and variations
// June 2, 2021

s.options.outDevice_("ZoomAudioD");
s.options.inDevice_("ZoomAudioD");

// SynthDefs are from here: https://github.com/SCLOrkHub/SCLOrkSynths
(
SynthDef(\cheapPiano1, {
	arg
	//Standard values
	out = 0, freq = 440, amp = 0.1, att = 0.001, rel = 1, pan = 0,
	//These range from 0 to 1
	tone = 0.25, hollowness = 0;

	var hammer, snd, delay, tonefreq, env;

	env = Env.perc(att, rel, amp * 4, -1).ar(doneAction: 2);

	// Delay line times: freq, freq - 4 cents, freq + 3 cents. In the original this was done by converting freq to midi.
	delay = (1 / (freq * [2.pow(-0.04/12), 1, 2.pow(0.03/12)]));
	tonefreq = tone.linlin(0, 1, 1000, 5000);

	hammer = Decay2.ar(
		in: Impulse.ar(0.001),
		attackTime: 0.008,
		decayTime: 0.04,
		mul: LFNoise2.ar(freq: amp.linlin(0, 1, tonefreq, 2 * tonefreq), mul: 0.25)
	); //Try LFNoise1, LFNoise0, or even LFClipNoise above for a slightly grainier sound.

	snd = CombL.ar(hammer, delay, delay, 50 * amp);
	snd = HPF.ar(snd, hollowness.linlin(0, 1, 50, 1000));
	snd = snd * env;
	snd = Limiter.ar(snd);
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "based on something posted 2008-06-17 by jeff, based on an old example by james mcc",
	category: \keyboards,
	tags: [\casio, \piano, \pitched]
)
).load(s);

SynthDef(\FMRhodes1, {
    arg
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1, att = 0.001, rel = 1, lfoSpeed = 4.8, inputLevel = 0.2,
    // all of these range from 0 to 1
    modIndex = 0.2, mix = 0.2, lfoDepth = 0.1;

    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    env1 = Env.perc(att, rel * 1.25, inputLevel, curve: \lin).kr;
    env2 = Env.perc(att, rel, inputLevel, curve: \lin).kr;
    env3 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;
    env4 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;

    osc4 = SinOsc.ar(freq) * 6.7341546494171 * modIndex * env4;
    osc3 = SinOsc.ar(freq * 2, osc4) * env3;
    osc2 = SinOsc.ar(freq * 30) * 0.683729941 * env2;
    osc1 = SinOsc.ar(freq * 2, osc2) * env1;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
  	snd = snd * (SinOsc.ar(lfoSpeed).range((1 - lfoDepth), 1));

    snd = snd * Env.asr(0, 1, 0.1).kr(gate: gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
},
metadata: (
	credit: "Nathan Ho",
	category: \keyboards,
	tags: [\pitched, \piano, \fm]
)
).load(s);

SynthDef(\FMRhodes2, {
    arg
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1, att = 0.001, rel = 1,
	//controls
	lfoSpeed = 2.4, inputLevel = 0.2, modIndex = 2, fmHarmonic = 30,
    // all of these range from 0 to 1
    mix = 0.2, lfoDepth = 0.75, lfoBottom = 0.15, lfoRange = 0.3;

    var env1, env2, env3, env4, range, bottom;
    var osc1, osc2, osc3, osc4, snd;

	bottom = lfoBottom.linlin(0, 1, 100, 12000);
	range = lfoRange.linlin(0, 1, bottom, 16000);

    env1 = Env.perc(att, rel * 1.25, inputLevel, curve: \lin).kr;
    env2 = Env.perc(att, rel, inputLevel, curve: \lin).kr;
    env3 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;
    env4 = Env.perc(att, rel * 1.5, inputLevel, curve: \lin).kr;

    osc4 = SinOsc.ar(freq) * 6.7341546494171 * modIndex * env4;
    osc3 = SinOsc.ar(freq * 2, osc4) * env3;
    osc2 = SinOsc.ar(freq * fmHarmonic) * 0.683729941 * env2;
    osc1 = SinOsc.ar(freq * 2, osc2) * env1;

    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
	snd = LPF.ar(snd, SinOsc.kr(lfoSpeed).range(bottom, range), lfoDepth) + (snd * (1 - lfoDepth));
    snd = snd * Env.asr(0, 1, 0.1).kr(gate: gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).load(s);


SynthDef("harpsichord1", { arg out = 0, freq = 440, amp = 0.05, pan = 0;
    var env, snd;
	env = Env.perc(level: amp).kr(doneAction: 2);
	snd = Pulse.ar(freq, 0.25, 0.75);
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "unknown",
	category: \keyboards,
	tags: [\pitched, \harpsichord]
)
).load(s);

SynthDef(\harpsichord2, {
	arg
	//Standard Values
	out = 0, amp = 0.25, freq = 440, pan = 0, rel = 5,
	//Pluck arguments (blend goes from 0 to 1)
	trig = 1, coef = 0.1, blend = 0.6;

	var exciter, root, octave, snd;

        // You can use white noise here, but Pink is more realistic
	exciter = PinkNoise.ar(amp);

	// Fundamental
        root = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/freq,
	        delaytime: 1/freq,
	        decaytime: rel,
	        coef: coef,
	        mul: blend
        );

	// Octave Above
	octave = Pluck.ar(
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 1/(2 * freq),
	        delaytime: 1/(2 * freq),
	        decaytime: rel,
	        coef: coef,
	        mul: (1 - blend)
        );

	// Output Stuff
	snd = Mix.ar(root + octave);
	snd = Limiter.ar(snd);

    DetectSilence.ar(in: snd, doneAction: 2);

	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Zé Craum",
	category: \keyboards,
	tags: [\pitched]
	)
).load(s);
)

// ----------------------------------------------------------------------------------------------------------------------
// I composed a round, which is written out in MIDI notes and note durations in forwardPitches and forwardDurations.

// This code can play the round as written, in reverse, in inversion, and retrograde inversion:
// ~forwardRound.play;
// ~reverseRound.play;
// ~invertRound.play;
// ~retroInvertRound.play;

// Flop was just for fun, messing around with the arrays to see what would happen
// ~flopRound.play;
// ~flop3Round.play;

(
// Variables for the streams and tasks
var forwardPitches, forwardDurations, forwardPitches1, forwardDurations1, forwardPitches2, forwardDurations2, forwardPitches3, forwardDurations3, forwardPitches4, forwardDurations4;

var reversePitches, reverseDurations, reversePitches1, reverseDurations1, reversePitches2, reverseDurations2, reversePitches3, reverseDurations3, reversePitches4, reverseDurations4;

var invertPitches, invertDurations, invertPitches1, invertDurations1, invertPitches2, invertDurations2, invertPitches3, invertDurations3, invertPitches4, invertDurations4;

var retroInvertPitches, retroInvertDurations, retroInvertPitches1, retroInvertDurations1, retroInvertPitches2, retroInvertDurations2, retroInvertPitches3, retroInvertDurations3, retroInvertPitches4, retroInvertDurations4;

var flopPitches, flopDurations, flopPitches1, flopDurations1, flopPitches2, flopDurations2, flopPitches3, flopDurations3, flopPitches4, flopDurations4;

var flop3Pitches, flop3Durations, flop3Pitches1, flop3Durations1, flop3Pitches2, flop3Durations2, flop3Pitches3, flop3Durations3, flop3Pitches4, flop3Durations4;

var instrument1, instrument2, instrument3, instrument4;

var freq, dur;

// ----------------------------------------------------------------------------------------------------------------------
// Variables for the GUI
var win, reset, forward, reverse, inverse, retroinv, flop, flop3, slider;

// Use these to keep track of whether to start the round or start the individual parts (after the round has begun)
// Don't stop the round until after all the voices have entered, or else some of the parts will automatically begin when the music resumes
var forwardStarted = 0;
var reverseStarted = 0;
var inverseStarted = 0;
var retroinvStarted = 0;
var flopStarted = 0;
var flop3Started = 0;

// ----------------------------------------------------------------------------------------------------------------------

// Notes of one part of the round, written in MIDI notes
forwardPitches = [64, 62, 60, 59, 60, 55, 67, 65, 64, 62, 64, 62, 60, 59, 60, 64, 67, 71, 69, 69, 67, 65, 64, 62, 60, 62, 60, 62, 64, 65, 67, 69, 71, 72, 71, 69, 67, 65, 64, 62, 60, 62, 64, 65, 67, 69, 67, 65];

// The note durations, written out as the number of 16th notes (aka 1 quarter note is written as a 4)
forwardDurations = [4, 2, 2, 2, 2, 4, 3, 1, 3, 1, 3, 1, 3, 1, 2, 2, 8, 2, 2, 4, 1, 1, 1, 1, 4, 4, 8, 4, 4, 4, 4, 6, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 5, 2, 2];

if (forwardPitches.size != forwardDurations.size) {
	"DIFFERENT NUMBER OF NOTES AND DURATIONS".postln;
};

~forwardPart1;
~forwardPart2;
~forwardPart3;
~forwardPart4;

~reversePart1;
~reversePart2;
~reversePart3;
~reversePart4;

~invertPart1;
~invertPart2;
~invertPart3;
~invertPart4;

~retroInvertPart1;
~retroInvertPart2;
~retroInvertPart3;
~retroInvertPart4;

~flopPart1;
~flopPart2;
~flopPart3;
~flopPart4;

~flop3Part1;
~flop3Part2;
~flop3Part3;
~flop3Part4;

~forwardRound;
~reverseRound;
~invertRound;
~retroInvertRound;
~flopRound;
~flop3Round;

// Changing ~divide will change the tempo, as ~divide is passed into the input for the duration of the Synths
// Don't change the tempo until all the parts have entered, otherwise some of the parts will be faster or slower than other parts
// since the previous divide value will be used
~divide = 7;

// ~size is the total number of notes before the line repeats
~size = forwardPitches.size;

// ~forwardDiff will hold the inverval differences between two notes to calculate inversion
// ~reverseDiff does the same, but in the reverse order
~forwardDiff = Array.new(~size);
~reverseDiff = Array.new(~size);

instrument1 = "harpsichord2";
instrument2 = \cheapPiano1;
instrument3 = \FMRhodes2;
instrument4 = "harpsichord1";

// ----------------------------------------------------------------------------------------------------------------------

// Retrograde/reverse
// Take the reverse of forwardPitches and forwardDurations
reversePitches = forwardPitches.reverse;
reverseDurations = forwardDurations.reverse;

// ----------------------------------------------------------------------------------------------------------------------

// Inversion
// Invert by calculating the difference between two notes, then subtracting from the previous note
// For example, [64, 62, 60] will become [64, 66, 68]
for (0, ~size-2, { arg i;
	~forwardDiff = ~forwardDiff.add(forwardPitches[i+1] - forwardPitches[i]);
});

/*
"FORWARD: ".postln;
forwardPitches.postln;

"DIFF: ".postln;
~forwardDiff.postln;
*/

invertPitches = Array.new(~size);
invertPitches = invertPitches.add(forwardPitches[0]);
for (1, ~size-1, { arg i;
	invertPitches = invertPitches.add(invertPitches[i-1] - ~forwardDiff[i-1]);
});

/*
"INVERT: ".postln;
invertPitches.postln;
*/

// by this point, invertPitches has been calculated and stored
// invertDurations is the same as forwardDurations
invertDurations = forwardDurations;

// ----------------------------------------------------------------------------------------------------------------------

// Retrograde inversion
// Reverse, then invert
for (0, ~size-2, { arg i;
	~reverseDiff = ~reverseDiff.add(reversePitches[i+1] - reversePitches[i]);
});

retroInvertPitches = Array.new(~size);
retroInvertPitches = retroInvertPitches.add(reversePitches[0]);
for (1, ~size-1, { arg i;
	retroInvertPitches = retroInvertPitches.add(retroInvertPitches[i-1] - ~reverseDiff[i-1]);
});

/*
"RETRO INVERT: ".postln;
retroInvertPitches.postln;
*/

// by this point, retroInvertPitches has been calculated and stored
// retroInvertDurations is the same as reverseDurations
retroInvertDurations = reverseDurations;

// ----------------------------------------------------------------------------------------------------------------------

// Clump, flop, and concatenate the pitches and durations to create something random-sounding
flopPitches = forwardPitches.clump(2).flop.reduce('++');
flopDurations = forwardDurations.clump(2).flop.reduce('++');

flop3Pitches = forwardPitches.clump(3).flop.reduce('++');
flop3Durations = forwardDurations.clump(3).flop.reduce('++');

// ----------------------------------------------------------------------------------------------------------------------

// Need to have separate Pseqs or else they get mixed up with each other
forwardPitches1   = Pseq(forwardPitches, inf).asStream;
forwardDurations1 = Pseq(forwardDurations, inf).asStream;

forwardPitches2   = Pseq(forwardPitches, inf).asStream;
forwardDurations2 = Pseq(forwardDurations, inf).asStream;

forwardPitches3   = Pseq(forwardPitches, inf).asStream;
forwardDurations3 = Pseq(forwardDurations, inf).asStream;

forwardPitches4   = Pseq(forwardPitches, inf).asStream;
forwardDurations4 = Pseq(forwardDurations, inf).asStream;

// ----------------------------------------------------------------------------------------------------------------------

reversePitches1   = Pseq(reversePitches, inf).asStream;
reverseDurations1 = Pseq(reverseDurations, inf).asStream;

reversePitches2   = Pseq(reversePitches, inf).asStream;
reverseDurations2 = Pseq(reverseDurations, inf).asStream;

reversePitches3   = Pseq(reversePitches, inf).asStream;
reverseDurations3 = Pseq(reverseDurations, inf).asStream;

reversePitches4   = Pseq(reversePitches, inf).asStream;
reverseDurations4 = Pseq(reverseDurations, inf).asStream;

// ----------------------------------------------------------------------------------------------------------------------

invertPitches1   = Pseq(invertPitches, inf).asStream;
invertDurations1 = Pseq(invertDurations, inf).asStream;

invertPitches2   = Pseq(invertPitches, inf).asStream;
invertDurations2 = Pseq(invertDurations, inf).asStream;

invertPitches3   = Pseq(invertPitches, inf).asStream;
invertDurations3 = Pseq(invertDurations, inf).asStream;

invertPitches4   = Pseq(invertPitches, inf).asStream;
invertDurations4 = Pseq(invertDurations, inf).asStream;

// ----------------------------------------------------------------------------------------------------------------------

retroInvertPitches1   = Pseq(retroInvertPitches, inf).asStream;
retroInvertDurations1 = Pseq(retroInvertDurations, inf).asStream;

retroInvertPitches2   = Pseq(retroInvertPitches, inf).asStream;
retroInvertDurations2 = Pseq(retroInvertDurations, inf).asStream;

retroInvertPitches3   = Pseq(retroInvertPitches, inf).asStream;
retroInvertDurations3 = Pseq(retroInvertDurations, inf).asStream;

retroInvertPitches4   = Pseq(retroInvertPitches, inf).asStream;
retroInvertDurations4 = Pseq(retroInvertDurations, inf).asStream;

// ----------------------------------------------------------------------------------------------------------------------

flopPitches1   = Pseq(flopPitches, inf).asStream;
flopDurations1 = Pseq(flopDurations, inf).asStream;

flopPitches2   = Pseq(flopPitches, inf).asStream;
flopDurations2 = Pseq(flopDurations, inf).asStream;

flopPitches3   = Pseq(flopPitches, inf).asStream;
flopDurations3 = Pseq(flopDurations, inf).asStream;

flopPitches4   = Pseq(flopPitches, inf).asStream;
flopDurations4 = Pseq(flopDurations, inf).asStream;

// ----------------------------------------------------------------------------------------------------------------------

flop3Pitches1   = Pseq(flop3Pitches, inf).asStream;
flop3Durations1 = Pseq(flop3Durations, inf).asStream;

flop3Pitches2   = Pseq(flop3Pitches, inf).asStream;
flop3Durations2 = Pseq(flop3Durations, inf).asStream;

flop3Pitches3   = Pseq(flop3Pitches, inf).asStream;
flop3Durations3 = Pseq(flop3Durations, inf).asStream;

flop3Pitches4   = Pseq(flop3Pitches, inf).asStream;
flop3Durations4 = Pseq(flop3Durations, inf).asStream;

// ----------------------------------------------------------------------------------------------------------------------

// Make a task for each part
~forwardPart1 = Task({
	inf.do{
		freq = forwardPitches1.next;
		dur = forwardDurations1.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~forwardPart2 = Task({
	inf.do{
		freq = forwardPitches2.next;
		dur = forwardDurations2.next/~divide;
		Synth(instrument2, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~forwardPart3 = Task({
	inf.do{
		freq = forwardPitches3.next;
		dur = forwardDurations3.next/~divide;
		Synth(instrument3, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~forwardPart4 = Task({
	inf.do{
		freq = forwardPitches4.next;
		dur = forwardDurations4.next/~divide;
		Synth(instrument4, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

// ----------------------------------------------------------------------------------------------------------------------

~reversePart1 = Task({
	inf.do{
		freq = reversePitches1.next;
		dur = reverseDurations1.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~reversePart2 = Task({
	inf.do{
		freq = reversePitches2.next;
		dur = reverseDurations2.next/~divide;
		Synth(instrument2, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~reversePart3 = Task({
	inf.do{
		freq = reversePitches3.next;
		dur = reverseDurations3.next/~divide;
		Synth(instrument3, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~reversePart4 = Task({
	inf.do{
		freq = reversePitches4.next;
		dur = reverseDurations4.next/~divide;
		Synth(instrument4, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

// ----------------------------------------------------------------------------------------------------------------------

~invertPart1 = Task({
	inf.do{
		freq = invertPitches1.next;
		dur = invertDurations1.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~invertPart2 = Task({
	inf.do{
		freq = invertPitches2.next;
		dur = invertDurations2.next/~divide;
		Synth(instrument2, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~invertPart3 = Task({
	inf.do{
		freq = invertPitches3.next;
		dur = invertDurations3.next/~divide;
		Synth(instrument3, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~invertPart4 = Task({
	inf.do{
		freq = invertPitches4.next;
		dur = invertDurations4.next/~divide;
		Synth(instrument4, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

// ----------------------------------------------------------------------------------------------------------------------

~retroInvertPart1 = Task({
	inf.do{
		freq = retroInvertPitches1.next;
		dur = retroInvertDurations1.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~retroInvertPart2 = Task({
	inf.do{
		freq = retroInvertPitches2.next;
		dur = retroInvertDurations2.next/~divide;
		Synth(instrument2, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~retroInvertPart3 = Task({
	inf.do{
		freq = retroInvertPitches3.next;
		dur = retroInvertDurations3.next/~divide;
		Synth(instrument3, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~retroInvertPart4 = Task({
	inf.do{
		freq = retroInvertPitches4.next;
		dur = retroInvertDurations4.next/~divide;
		Synth(instrument4, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

// ----------------------------------------------------------------------------------------------------------------------

~flopPart1 = Task({
	inf.do{
		freq = flopPitches1.next;
		dur = flopDurations1.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~flopPart2 = Task({
	inf.do{
		freq = flopPitches2.next;
		dur = flopDurations2.next/~divide;
		Synth(instrument2, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~flopPart3 = Task({
	inf.do{
		freq = flopPitches3.next;
		dur = flopDurations3.next/~divide;
		Synth(instrument3, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~flopPart4 = Task({
	inf.do{
		freq = flopPitches4.next;
		dur = flopDurations4.next/~divide;
		Synth(instrument4, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

// ----------------------------------------------------------------------------------------------------------------------

~flop3Part1 = Task({
	inf.do{
		freq = flop3Pitches1.next;
		dur = flop3Durations1.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~flop3Part2 = Task({
	inf.do{
		freq = flop3Pitches2.next;
		dur = flop3Durations2.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~flop3Part3 = Task({
	inf.do{
		freq = flop3Pitches3.next;
		dur = flop3Durations3.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

~flop3Part4 = Task({
	inf.do{
		freq = flop3Pitches4.next;
		dur = flop3Durations4.next/~divide;
		Synth(instrument1, [\freq, freq.midicps, \dur, dur]);
		dur.wait;
	}
});

// ----------------------------------------------------------------------------------------------------------------------

// Wrap the tasks into a larger task to get entrances every two measures
// Wait two measures, or 32-sixteenth notes in between each entrance
~forwardRound = Task({
	~forwardPart1.start;
	(32/~divide).wait;
	~forwardPart2.start;
	(32/~divide).wait;
	~forwardPart3.start;
	(32/~divide).wait;
	~forwardPart4.start;
});

~reverseRound = Task({
	~reversePart4.start;
	(32/~divide).wait;
	~reversePart3.start;
	(32/~divide).wait;
	~reversePart2.start;
	(32/~divide).wait;
	~reversePart1.start;
});

~invertRound = Task({
	~invertPart1.start;
	(32/~divide).wait;
	~invertPart2.start;
	(32/~divide).wait;
	~invertPart3.start;
	(32/~divide).wait;
	~invertPart4.start;
});

~retroInvertRound = Task({
	~retroInvertPart4.start;
	(32/~divide).wait;
	~retroInvertPart3.start;
	(32/~divide).wait;
	~retroInvertPart2.start;
	(32/~divide).wait;
	~retroInvertPart1.start;
});

~flopRound = Task({
	~flopPart1.start;
	(32/~divide).wait;
	~flopPart2.start;
	(32/~divide).wait;
	~flopPart3.start;
	(32/~divide).wait;
	~flopPart4.start;
});

~flop3Round = Task({
	~flop3Part1.start;
	(32/~divide).wait;
	~flop3Part2.start;
	(32/~divide).wait;
	~flop3Part3.start;
	(32/~divide).wait;
	~flop3Part4.start;
});

//~forwardRound.play;
//~reverseRound.play;
//~invertRound.play;
//~retroInvertRound.play;
//~flopRound.play;
//~flop3Round.play;

win = Window("Play");

// To start from the beginning again, the sequences must be reassigned to the original array values
reset = Button()
.action_{|pressed|
	"reset".postln;
	forwardStarted = 0;
	reverseStarted = 0;
	inverseStarted = 0;
	retroinvStarted = 0;
	flopStarted = 0;
	flop3Started = 0;
	forwardPitches1   = Pseq(forwardPitches, inf).asStream;
	forwardDurations1 = Pseq(forwardDurations, inf).asStream;
	forwardPitches2   = Pseq(forwardPitches, inf).asStream;
	forwardDurations2 = Pseq(forwardDurations, inf).asStream;
	forwardPitches3   = Pseq(forwardPitches, inf).asStream;
	forwardDurations3 = Pseq(forwardDurations, inf).asStream;
	forwardPitches4   = Pseq(forwardPitches, inf).asStream;
	forwardDurations4 = Pseq(forwardDurations, inf).asStream;
	reversePitches1   = Pseq(reversePitches, inf).asStream;
	reverseDurations1 = Pseq(reverseDurations, inf).asStream;
	reversePitches2   = Pseq(reversePitches, inf).asStream;
	reverseDurations2 = Pseq(reverseDurations, inf).asStream;
	reversePitches3   = Pseq(reversePitches, inf).asStream;
	reverseDurations3 = Pseq(reverseDurations, inf).asStream;
	reversePitches4   = Pseq(reversePitches, inf).asStream;
	reverseDurations4 = Pseq(reverseDurations, inf).asStream;
	invertPitches1   = Pseq(invertPitches, inf).asStream;
	invertDurations1 = Pseq(invertDurations, inf).asStream;
	invertPitches2   = Pseq(invertPitches, inf).asStream;
	invertDurations2 = Pseq(invertDurations, inf).asStream;
	invertPitches3   = Pseq(invertPitches, inf).asStream;
	invertDurations3 = Pseq(invertDurations, inf).asStream;
	invertPitches4   = Pseq(invertPitches, inf).asStream;
	invertDurations4 = Pseq(invertDurations, inf).asStream;
	retroInvertPitches1   = Pseq(retroInvertPitches, inf).asStream;
	retroInvertDurations1 = Pseq(retroInvertDurations, inf).asStream;
	retroInvertPitches2   = Pseq(retroInvertPitches, inf).asStream;
	retroInvertDurations2 = Pseq(retroInvertDurations, inf).asStream;
	retroInvertPitches3   = Pseq(retroInvertPitches, inf).asStream;
	retroInvertDurations3 = Pseq(retroInvertDurations, inf).asStream;
	retroInvertPitches4   = Pseq(retroInvertPitches, inf).asStream;
	retroInvertDurations4 = Pseq(retroInvertDurations, inf).asStream;
	flopPitches1   = Pseq(flopPitches, inf).asStream;
	flopDurations1 = Pseq(flopDurations, inf).asStream;
	flopPitches2   = Pseq(flopPitches, inf).asStream;
	flopDurations2 = Pseq(flopDurations, inf).asStream;
	flopPitches3   = Pseq(flopPitches, inf).asStream;
	flopDurations3 = Pseq(flopDurations, inf).asStream;
	flopPitches4   = Pseq(flopPitches, inf).asStream;
	flopDurations4 = Pseq(flopDurations, inf).asStream;
	flop3Pitches1   = Pseq(flop3Pitches, inf).asStream;
	flop3Durations1 = Pseq(flop3Durations, inf).asStream;
	flop3Pitches2   = Pseq(flop3Pitches, inf).asStream;
	flop3Durations2 = Pseq(flop3Durations, inf).asStream;
	flop3Pitches3   = Pseq(flop3Pitches, inf).asStream;
	flop3Durations3 = Pseq(flop3Durations, inf).asStream;
	flop3Pitches4   = Pseq(flop3Pitches, inf).asStream;
	flop3Durations4 = Pseq(flop3Durations, inf).asStream;
	~forwardRound.reset;
	~forwardPart1.reset;
	~forwardPart2.reset;
	~forwardPart3.reset;
	~forwardPart4.reset;
	~reverseRound.reset;
	~reversePart1.reset;
	~reversePart2.reset;
	~reversePart3.reset;
	~reversePart4.reset;
	~invertRound.reset;
	~invertPart1.reset;
	~invertPart2.reset;
	~invertPart3.reset;
	~invertPart4.reset;
	~retroInvertRound.reset;
	~retroInvertPart1.reset;
	~retroInvertPart2.reset;
	~retroInvertPart3.reset;
	~retroInvertPart4.reset;
	~flopRound.reset;
	~flopPart1.reset;
	~flopPart2.reset;
	~flopPart3.reset;
	~flopPart4.reset;
	~flop3Round.reset;
	~flop3Part1.reset;
	~flop3Part2.reset;
	~flop3Part3.reset;
	~flop3Part4.reset;
};

// For each button, if the round Task was not previously started, then start the round.
// If the round Task has already been started before, then start the individual parts (don't wait extra time in between the parts)
forward = Button()
.states_([
	["", Color.green, Color.white],
	["", Color.white, Color.green]
])
.action_{|pressed|
	if (pressed.value == 1 && forwardStarted == 0) {
		forwardStarted = 1;
		~forwardRound.start;
	} {
		if (pressed.value == 1 && forwardStarted == 1) {
			~forwardPart1.start;
			~forwardPart2.start;
			~forwardPart3.start;
			~forwardPart4.start;
		} {
			~forwardRound.pause;
			~forwardPart1.pause;
			~forwardPart2.pause;
			~forwardPart3.pause;
			~forwardPart4.pause;
		};
	};
};

reverse = Button()
.states_([
	["", Color.green, Color.white],
	["", Color.white, Color.green]
])
.action_{|pressed|
	if (pressed.value == 1 && reverseStarted == 0) {
		reverseStarted = 1;
		~reverseRound.start;
	} {
		if (pressed.value == 1 && reverseStarted == 1) {
			~reversePart1.start;
			~reversePart2.start;
			~reversePart3.start;
			~reversePart4.start;
		} {
			~reverseRound.pause;
			~reversePart1.pause;
			~reversePart2.pause;
			~reversePart3.pause;
			~reversePart4.pause;
		};
	};
};

inverse = Button()
.states_([
	["", Color.green, Color.white],
	["", Color.white, Color.green]
])
.action_{|pressed|
	if (pressed.value == 1 && inverseStarted == 0) {
		inverseStarted = 1;
		~invertRound.start;
	} {
		if (pressed.value == 1 && inverseStarted == 1) {
			~invertPart1.start;
			~invertPart2.start;
			~invertPart3.start;
			~invertPart4.start;
		} {
			~invertRound.pause;
			~invertPart1.pause;
			~invertPart2.pause;
			~invertPart3.pause;
			~invertPart4.pause;
		};
	};
};

retroinv = Button()
.states_([
	["", Color.green, Color.white],
	["", Color.white, Color.green]
])
.action_{|pressed|
	if (pressed.value == 1 && retroinvStarted == 0) {
		retroinvStarted = 1;
		~retroInvertRound.start;
	} {
		if (pressed.value == 1 && retroinvStarted == 1) {
			~retroInvertPart1.start;
			~retroInvertPart2.start;
			~retroInvertPart3.start;
			~retroInvertPart4.start;
		} {
			~retroInvertRound.pause;
			~retroInvertPart1.pause;
			~retroInvertPart2.pause;
			~retroInvertPart3.pause;
			~retroInvertPart4.pause;
		};
	};
};

flop = Button()
.states_([
	["", Color.green, Color.white],
	["", Color.white, Color.green]
])
.action_{|pressed|
	if (pressed.value == 1 && flopStarted == 0) {
		flopStarted = 1;
		~flopRound.start;
	} {
		if (pressed.value == 1 && flopStarted == 1) {
			~flopPart1.start;
			~flopPart2.start;
			~flopPart3.start;
			~flopPart4.start;
		} {
			~flopRound.pause;
			~flopPart1.pause;
			~flopPart2.pause;
			~flopPart3.pause;
			~flopPart4.pause;
		};
	};
};

flop3 = Button()
.states_([
	["", Color.green, Color.white],
	["", Color.white, Color.green]
])
.action_{|pressed|
	if (pressed.value == 1 && flop3Started == 0) {
		flop3Started = 1;
		~flop3Round.start;
	} {
		if (pressed.value == 1 && flop3Started == 1) {
			~flop3Part1.start;
			~flop3Part2.start;
			~flop3Part3.start;
			~flop3Part4.start;
		} {
			~flop3Round.pause;
			~flop3Part1.pause;
			~flop3Part2.pause;
			~flop3Part3.pause;
			~flop3Part4.pause;
		};
	};
};

// The mininum slider value is 5, the maximum slider value is 9
slider = Slider()
.action_{|sl| ~divide = sl.value.linlin(0, 1, 5, 9)}
.valueAction_(0.5)
.background_(Color.white)
.orientation_(\horizontal);

win.layout_(
	VLayout(
		HLayout(StaticText().string_("Reset"), reset),
		HLayout(StaticText().string_("Regular"), forward),
		HLayout(StaticText().string_("Retrograde"), reverse),
		HLayout(StaticText().string_("Inversion"), inverse),
		HLayout(StaticText().string_("Retrograde Inversion"), retroinv),
		HLayout(StaticText().string_("Flop 2/3"), flop, flop3),
		HLayout(StaticText().string_("Tempo"), slider)
	)
);
win.front;
)