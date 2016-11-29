(
// if you want to set a different port for your server.
// s = Server("peev",NetAddr("localhost",57556));
// Server.default = s; 
s.options.sampleRate = 48000;
s.options.memSize = 262144;
s.boot;
s.doWhenBooted{
var sb, sad, melo, voc, genArgs, nudgeArgs, playThem, stopThem, synths, holdIt = false, puff, puffIt = 0, soothIt, munch, goons, saddy, freends, hurt, amper, eTime = 37, doneDid = false, startUp, shutDown, win, butt, acs;

sb = Environment.make({
	~b = Buffer.alloc(s, 2048, 1, {|buf|
		buf.chebyMsg(Array.fill(64, {|i| (i % 2 == 0).if({ (i + 1).squared.reciprocal }, { 0.5.rand / (i + 1).squared }) })) 
	});
	
	~c = Buffer.alloc(s, 2048, 1, {|buf|
		buf.chebyMsg(Array.fill(64, {|i| (i % 2 == 1).if({ (i + 1).reciprocal }, { 0.3.rand / (i + 1) }) }))
	});
	
	~d = Buffer.alloc(s, 2048, 1, {|buf|
		buf.chebyMsg(Array.fill(64, {|i| (i % 2 == 0).if({ (i + 1).squared.reciprocal }, { 0.5.rand / (i + 1).squared }) }))
	});
	
	~e = Buffer.alloc(s, 2048, 1, {|buf|
		buf.chebyMsg(Array.fill(64, {|i| (i % 2 == 1).if({ (i + 1).reciprocal }, { 0.5.rand / (i + 1) }) }))
	});
	
	~f = Buffer.alloc(s, 2048, 1, {|buf|
		buf.chebyMsg(Array.fill(64, {|i| (i % 2 == 0).if({ (i + 1).squared.reciprocal }, { 0.2.rand / (i + 1).squared }) }))
	});
});

sad = Buffer.read(s, Document.current.dir ++ "/audio/sax-bright-01.wav");
melo = Buffer.read(s, Document.current.dir ++ "/audio/sax-bright-02.wav");
voc = Buffer.read(s, Document.current.dir ++ "/audio/voc-01.wav");

SynthDef(\mouth, {|amp=1, f=3305, fr=0.25, fd=0.2, ar=4, ad=0.9, a=0.1, b=0.1, c=0.2, d=0.2, gate=1, fade=3, pan=0, shapeBuf=0, out=0|
	var sig, env, fmod, amod;
	fr = fr.lag(Rand(1.0,3.0));
	fd = fd.lag(Rand(0.9, 2.0));
	ar = ar.lag(Rand(1.0, 3.0));
	ad = ad.lag(Rand(0.9, 2.0));
	fmod = Select.kr(TIRand.kr(0,2,gate), [LFNoise2.kr(fr, fd), LFSaw.kr((fr * 2).ring1(LFNoise1.kr(fr, 0.5)), 1, fd * TChoose.kr(gate, [-1, 1])), Gendy4.kr(minfreq: fr * 0.041, maxfreq: fr * 0.16, ampscale: 0.25, durscale: 0.9).clip2(1.0) * fd * ToggleFF.kr(Dust.kr(fr * 0.4)).lag(Rand(0.5, 1.5))]);
	amod = Select.kr(TIRand.kr(0,1,gate), [LFNoise2.kr(ar, ad), Gendy4.kr(minfreq: ar * 0.041, maxfreq: ar * 0.16, ampscale: 0.25, durscale: 0.9).clip2(1.0) * ad  * ToggleFF.kr(Dust.kr(ar * 0.5)).lag(Rand(0.5, 1.5))]);
	sig=OnePole.ar(
		LeakDC.ar(
			Shaper.ar(
				shapeBuf, 
				LeakDC.ar(
					Fhn2DL.ar(
						60, 
						f.lag(Rand(0.9, 3.0)).ring1(fmod), 
						a.lag(Rand(0.9, 1.7)), 
						b.lag(Rand(0.9, 1.8)), 
						c.lag(Rand(0.9, 1.4)), 
						d.lag(Rand(1.0, 3.0)), 
						mul:amp.min(1).lag(Rand(1.0, 3.0)).ring1(amod)
					)
				)
			)
		), 
		Rand(0.5, 0.81)
	).tanh;
	env=EnvGen.kr(Env.asr(fade, 1, fade), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(sig * env, pan));
}).send(s);

SynthDef(\gverb, {|roomsize, revtime, damping, inputbw, spread = 15, drylevel, earlylevel, taillevel, in=21, out=42|
	var a = In.ar(in, 2);
	Out.ar(out, GVerb.ar(a,roomsize,revtime,damping,inputbw,spread,drylevel,earlylevel,taillevel,roomsize,0.3)
	)
}).send(s);

SynthDef(\unMuddy, {|in=42|
	var i = In.ar(in, 2);
	Out.ar(0, BPeakEQ.ar(BPeakEQ.ar(BPeakEQ.ar(i, 250, 0.84.reciprocal, -1), 10000, 1.2, 1.5), 52, 0.5, 1.8) * 0.7);
}).send(s);

SynthDef(\getAmps, {
	var amp, in = In.ar(0, 2).mean, nan;
	nan = BinaryOpUGen('==', CheckBadValues.ar(in), 1);
	amp = Amplitude.kr(HPF.ar(in, 80), 0.1, 0.3);
	SendTrig.kr(Dust.kr(0.5), 1001, amp);	
	SendTrig.ar(nan, 1002, 1);
}).send(s);

SynthDef(\puff, {|a=1.03, c=1.01, gate=0, amp=1, out=0| 
	var sig = Latoocarfian2DL.ar(3000, 48000, TRand.kr(1.0, 1.097, gate), LFBrownNoise2.kr(TExpRand.kr(12.0, 17.0, gate)).exprange(2.0, 2.09), c.lag(0.1), LFBrownNoise2.kr(TExpRand.kr(12.0, 17.0, gate)).range(1.041, 1.055), [0.3, 0.2, 0.1], mul: 0.1); 
	Out.ar(out, OnePole.ar(LeakDC.ar(Splay.ar(sig)), 0.3) * amp.lag(2.0) * EnvGen.kr(Env.asr(4.0, 1, 10.0), gate));
}).send(s);

SynthDef(\munchy, {|gate = 1, vol = 0.7, out = 0|
	var sig, n1, n2, amp, full, half, pitchyL, pitchyR;
	sig=Fhn2DL.ar(20, 60, 0.2, 0.3, LFNoise1.kr(5.dup).range(0.1, 0.8), LFNoise0.kr(2.dup).range(0.1, 0.8), mul: 0.8).clip2(0.8);
	n1 = LFBrownNoise0.kr(5.dup, 0.75, 2);
	n2 = TWChoose.kr(Dust.kr(0.3333), [LFBrownNoise0.kr(LFNoise2.kr.dup.exprange(2.7,4.0), 0.75, TChoose.kr(Dust.kr(1), [2,2,2,2,4])), LFBrownNoise2.kr(6.dup, 0.75, TChoose.kr(Dust.kr(1), [2,2,4]))], [0.6,0.4]);
	amp = (n1 + n2 / 2).lag(0.1);
	full = BPeakEQ.ar(LPF.ar(LeakDC.ar(Friction.ar(sig, friction: n1.exprange(0.0004, 0.0012), mass: n2.exprange(0.42,0.5), spring: 0.99, mul: amp.squared * 18  + 7)), 12000), 13000, 0.5, -20).tanh;
	pitchyL = Pitch.kr(LPF.ar(full[0],2500), minFreq: 40, median: 5, clar: 0.1);
	pitchyR = Pitch.kr(LPF.ar(full[1],2500), minFreq: 40, median: 5, clar: 0.1);
	half = Pulse.ar(([pitchyL[0], pitchyR[0]] * 0.5).max(18), mul: ([pitchyL[1], pitchyR[1]].lag(0.067) * amp * 0.3).squared);
	sig = OnePole.ar(HPF.ar(full + DelayC.ar(half,0.2,0.1), 22), 0.25);
	sig = Rotate2.ar(sig[0], sig[1], LFNoise2.kr(0.125, 0.5)) * LFNoise0.kr(0.5, 2, 1.9).max(0).round.lag(2.0) * 0.5 * EnvGen.kr(Env.asr(3.0, 1, 6), gate);
	Out.ar(out, sig * vol);
}).send(s);

SynthDef(\saddy, {|rate=0.5, spread=1.0, bufnum=0, gate=0, out=0|
	var i, chain, n1, n2, o, e;
	e = EnvGen.kr(Env.asr(1.0, 1, 3), gate);
	i = LeakDC.ar(PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) * rate * e, loop: 1));
	n1 = LFBrownNoise1.kr(1, 0.3, 1);
	n2 = LFBrownNoise1.kr(1, 0.3, 1);
	chain = FFT({ LocalBuf(2048, 1) }.dup, i);
	chain = PV_MagSmear(chain, n1.exprange(0.3, 30));
	o = IFFT(chain);
	o = Splay.ar(DelayC.ar(PitchShift.ar(o, 0.2, n1.range(1, [0.6667, 0.5]), timeDispersion: { exprand(0.001, 0.05) }.dup), 0.2, Array.rand(2, 0.02, 0.2) * n1.range(0, 1.0)), spread) * n2.range(0.3, 1).squared;
	Out.ar(out, o * e);
}).send(s);

SynthDef(\hurt, {|bufnum=0, yes=0, out=0|
	var e,v,sig;
	e = EnvGen.kr(Env.asr(3, 1, 8), yes);
	v = LFNoise2.kr(0.5.dup, 0.8, 0.2).max(0);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * TRand.kr(0.5.dup, 1.0, v), yes, TRand.kr(0, BufFrames.kr(bufnum), yes), 1) * v;
	sig = Rotate2.ar(sig[0],sig[1],LFBrownNoise2.kr(0.25, mul: 0.4)) * e;
	Out.ar(out, sig);
}).send(s);

SynthDef(\soothy, {|f_mul=1, r_mul=0.9, gate=1, amp=1, out=0|
	var ratios, sig, del, sigenv, delenv;
	ratios = [19.02, 21.69, 0, 28.98, 26.04, 33.69, 12, 31.02];
	sig = VarSaw.ar(
		(Select.kr((Hasher.kr(
			Latch.kr(SinOsc.kr((1..4)!2 * r_mul),Impulse.kr([0.5,0.833] * r_mul)
			)
		).range(0, 7)).round, ratios) + (LFNoise2.kr(0.25).range(50, 56) * f_mul)).midicps.lag(0.067),
		0,
		LFNoise2.kr(2,0.3,0.5)
	) * 0.667;
	sig = Mix(sig).tanh;
	del = CombN.ar(BPF.ar(sig.mean, 1200, 0.2), 0.5, 0.4, 3);
	sigenv = EnvGen.kr(Env.asr(8, 1, 10), gate, doneAction: 2);
	delenv = EnvGen.kr(Env.asr(8, 1, 10, 4), gate, doneAction: 2);
	Out.ar(out, delenv * del.dup * 0.5 + Splay.ar(sig * sigenv, LFNoise2.kr(0.25, 0.5, 0.5)) * amp);
}).send(s);

// generate Synth args
genArgs = {|n, i, makeOut = true|
	var 
		a = exprand(0.006667, 0.3),
		b,
		c = rrand(0.1, 0.4),
		d,
		f = [2200, 3305, 8192, 13305, 22000].choose,
		buf = [\b, \c, \d, \e, \f].wchoose([0.2,0.1,0.6,0.05,0.05]),
		ar, ad, fr, fd, amp, pan, out, set;
	
	(doneDid).if({
		b = a * exprand(0.5, 0.99);
		d = rrand(1.08, 1.9);
	}, {
		b = exprand(0.006667, 0.3);
		d = rrand(0.85, 1.9);
	});
	
	(a < b).if({
		var tmpa;
		tmpa = a;
		a = b;
		b = tmpa;
	});
	(d >= 1.0).if({
		ar = exprand(3.0, 7.0);
		ad = rrand(0.85, 0.95);
		fr = exprand(0.05, 0.7);
		fd = rrand(0.02, 0.5);
		amp = rrand(0.6, 0.9);
		(doneDid).if({
			out = [42, 32, 34, 36, 38].wchoose([0.25, 0.275, 0.275, 0.1, 0.1]);
		}, {
			out = [42, 32, 34, 36, 38].wchoose([0.4, 0.225, 0.225, 0.05, 0.1]);
		});
	}, {
		ar = exprand(2.0, 5.0);
		ad = rrand(0.15, 0.94);
		fr = [exprand(0.05, 0.3), exprand(0.5, 8.0)].wchoose([0.8, 0.2]);
		(fr > 3.0).if({
			fd = rrand(0.3, 0.6);
		}, {
			fd = rrand(0.02, 0.25);
		});
		(b / a > 0.9).if({
			fr = fr * 0.1;
		});
		amp = rrand(0.7, 0.93).squared;
		out = [42, 42, 42, 32, 34, 36, 36, 38].choose;
	});
	
	(n <= 1).if({
		pan = rrand(-0.6, 0.6);
	}, {
		pan = i / (n - 1) * 2 - 1
	});
	set = [
		\f, f,
		\a, a, 
		\b, b,
		\c, c,
		\d, d,
		\ar, ar,
		\ad, ad,
		\fr, fr,
		\fd, fd,
		\amp, amp,
		\pan, pan,
		\fade, rrand(1.0, 8.0)
	];
	// set.postln;
	(makeOut).if({
		set = set ++ [\out, out, \shapeBuf, sb[buf].bufnum];
	});
	set;
};

// just push the args around a bit
nudgeArgs = {
	var gets = [\a, \b, \c, \d, \fr, \fd, \ar, \ad, \amp];
	synths.do({|e, c|
		gets.do({|f, i|
			e.get(f, {|v|
				((f == \fd) || (f == \ad)).if({
					e.set(f, v * rrand(0.9, 1));
				}, {
					(f == \amp).if({
						e.set(f, v * rrand(0.95, 1.01));
					}, {
						e.set(f, v * rrand(0.97, 1.02));
					});
				});
			});
		});
	});
};

// function for playing
playThem = {|n|
	var newsynths, doNew = true;
	(synths.size > 0).if({
		(0.45.coin).if({ 
			(0.5.coin).if({
				stopThem.value;
			}, {
				rrand(synths.size * 0.5, synths.size).round.do({
					var t;
					t = synths.removeAt(rrand(0, synths.size - 1));
					t.release;
				});
			});
			
		}, {
			(eTime.lincurve(5.0, 37, 0.8, 0.6, -4).coin).if({
				// just set new args for current synths
				(eTime.lincurve(5.0, 37, 0.85, 0.7, -2).coin).if({
					nudgeArgs.value;
				}, {
					{
						var reset = false;
						// 'reseting'.postln;
						(0.4.coin).if({
							goons.set(\amp, 0);
							puff.set(\amp, 0);
							amper.run(false);
							0.2.wait;
							holdIt = true;
							exprand(0.8, 3.0).wait;
							reset = true;
						});
						synths.do({|e, c|
							var args;
							args = genArgs.value(synths.size, c, false);
							(0.7.coin).if({
								args.do({|a, i|
									(i.odd).if({
										(0.9.coin || ((i > 0) && (args[i - 1] == \amp))).if({ 
											e.set(args[i - 1], a); 
										});
									});
								});
							}, {
								e.set(\amp, args[args.indexOf(\amp) + 1]);
							});
						});
						(reset).if({
							amper.run(true);
							holdIt = false;
						});
						// 'done reseting'.postln;
					}.fork;
				});
				doNew = false;
			}, {
				((synths.size > n) && 0.5.coin).if({
					rrand(n * 0.25, n * 0.75).round.do({
						var t;
						t = synths.removeAt(rrand(0, synths.size - 1));
						t.release;
					});
				});	
			});
		});
	});	
	(doNew).if({
		newsynths = Array.fill(n, {|i|
			Synth(\mouth, genArgs.value(n, i), goons);
		});	
		synths = synths ++ newsynths;
		((synths.size > 13) && (eTime > 35)).if({
			doneDid = false;
		});
	});
	(0.6.coin).if({
		puffIt = (puffIt - 1).abs;
		puff.set(\gate, puffIt);
	});
	// " ".postln;
};

// function for stopping
stopThem = {
	goons.release;
	synths = [];	
};

soothIt = {
	var n = synths.size, sooths = List.new;
	synths.do({|e, c|
		e.release;
	});
	puffIt = 0;
	freends.set(\gate, 0);
	synths = [];
	{
		rrand(2, 4).do({
			sooths.add(Synth(\soothy, [\f_mul, rrand(0.75, 1.05), \r_mul, rrand(0.75, 1.1), \amp, rrand(0.8, 1.0), \out, 38], goons));
			rrand(1.5, 3.0).wait;
		});
		rrand(5, 12.0).wait;
		munch.set(\gate, 1);
		sooths.do({|e, c|
			e.release;
		});
		(synths.size < 3).if({
			playThem.value(n);
		});
	}.fork;	
};
// mouse click, amplitude, and NaN OSC responder 
OSCdef(\clerk, {|msg, time|
	(msg[2] < 1001).if({
		(holdIt.not).if({
			holdIt = true;
			(msg[3] > 0).if({
				// eTime.postln;
				([21, 23, 26, 29].includes(eTime.floor.asInteger)).if({
					soothIt.value();
				}, {
					playThem.value(rrand(eTime.lincurve(5, 37.0, 1, 6, -4), eTime.lincurve(5, 37.0, 1, 13, -4)).round);
				});
			}, {
				var args, noSet;
				args = genArgs.value(1, 0, false);
				noSet = [\amp, \pan];
				args.do({|e, c|
					(c.even && noSet.indexOf(e).isNil).if({
						goons.set(e, args[c + 1]);
					});
				});
			});
			{ 0.2.wait; holdIt = false }.fork;
			eTime = (eTime * rrand(1.25, 2)).min(37);
		});
	}, {
		(msg[2] == 1002).if({
			// Check bad values got a bad value
			amper.free;
			amper = Synth.tail(goons, \getAmps);
		}, {
			// we're getting amplitude for mouths and stuff
			// msg[3].postln;
			(msg[3] < 0.041).if({
				saddy.set(\gate, 1);
				puff.set(\amp, 0.1);
				hurt.set(\yes, 1);
			}, {
				(0.87.coin).if({ saddy.set(\gate, 0); });
				puff.set(\amp, rrand(0.75, 1.0).squared);
				(0.1.coin).if({ hurt.set(\yes, 0) });
			});
		});
	});
	},'/tr', s.addr);

/////////////////
// the game being afoot //
startUp = {
	{
		goons = Group.new;
		saddy = Group.new;
		freends = Group.new;
		s.sync;
		
		munch = Synth(\munchy, target: freends);
		puff = Synth(\puff, target: freends);
		
		amper = Synth(\getAmps, target: goons);
		Synth(\unMuddy, target: goons);
		
		// play some gverbs
		Synth(\gverb, [\roomsize, 5, \revtime, 0.6, \damping, 0.62, \inputbw, 0.48, \drylevel, -3.dbamp, \earlylevel, -11.dbamp, \taillevel, -13.dbamp, \in, 32], goons);
		Synth(\gverb, [\roomsize, 16, \revtime, 1.24, \damping, 0.10, \inputbw, 0.95, \drylevel, -3.dbamp, \earlylevel, -15.dbamp, \taillevel, -17.dbamp, \in, 34], goons);
		Synth(\gverb, [\roomsize, 80, \revtime, 4.85, \damping, 0.41, \inputbw, 0.19, \drylevel, -3.dbamp, \earlylevel, -12.dbamp, \taillevel, -14.dbamp, \in, 36], goons);
		Synth(\gverb, [\roomsize, 243, \revtime, 1, \damping, 0.1, \inputbw, 0.34, \drylevel, -3.dbamp, \earlylevel, -13.dbamp, \taillevel, -11.dbamp, \in, 38], goons);
		
		hurt = Synth(\hurt, [\bufnum, voc.bufnum, \out, 36], goons);
		
		Synth(\saddy, [\bufnum, sad.bufnum, \rate, 0.4], saddy);
		Synth(\saddy, [\bufnum, melo.bufnum, \spread, 0.5, \rate, 0.2], saddy);
		
		// get yer mouse clicks
		{ SendTrig.kr(MouseButton.kr, 1000, MouseX.kr * MouseY.kr) }.play(goons);
		
		OSCdef(\clerk).enable;
		s.sync;
		
		playThem.value(rrand(6, 13));
		
		acs = Array.newClear(3);
		// the puff might pop by
		acs[0] = AppClock.sched(1.0, {|t|
			(puffIt > 0).if({
				(0.1.coin).if({
					puffIt = 0;
				});
			}, {
				(0.02.coin).if({
					puffIt = 1;
				});
			});
			puff.set(\gate, puffIt);	
			rrand(1.0, 2.0);
		});
		
		// if you just let it idle, synth values change. 
		acs[1] = AppClock.sched(eTime, {|t|
			(eTime.lincurve(5.0, 37, 0.1, 1, -6).coin).if({
				nudgeArgs.value;
			});
			eTime = (eTime * rrand(0.667, 0.95)).max(5.0);
			eTime;
		});
		
		// entropy
		acs[2] = AppClock.sched(eTime * 0.3333333, {|t|
			((synths.size > 0) && holdIt.not && 0.3.coin).if({
				// drop one
				var target = rrand(0, synths.size - 1).round;
				target = synths.removeAt(target);
				target.release;
			});
			(0.13.coin).if({
				// double the mods for a little
				var fr, ar, fd, dead = List.new;
				synths.do({|e, i|
					(0.6.coin).if({
						ar = exprand(4.0, 11.0);
						fr = exprand(1.0, 5.0);
						(fr > 3.0).if({
							fd = rrand(0.1, 0.7); // seems like higher values lead to lack of recovery - maybe that's cool
						}, {
							fd = rrand(0.05, 0.4);
						});
						e.set(\ar, ar, \fr, fr, \fd, fd);
						(fd.coin).if({
							dead.add(e);
							e.release;
						});
					});
				});
				synths.removeAll(dead);
				{
					rrand(2.0, 5.0).wait;
					ar = exprand(3.0, 7.0);
					fr = exprand(0.05, 0.7);
					fd = rrand(0.02, 0.1);
					goons.set(\ar, ar, \fr, fr, \fd, fd);
				}.fork;
			});
			(synths.size < 3).if({
				doneDid = true;
			});
			eTime * 0.3333333;
		});
	}.fork(AppClock);
};
shutDown = {
	OSCdef(\clerk).disable;
	acs.do({|e, c|
		e.clear;
	});
	goons.free;
	saddy.free;
	freends.free;
	synths=[];
};
"Welcome to peev".postln;
win = Window.new("peev", Rect(300, 600, 150, 90), false).userCanClose_(false);
butt = Button(win, Rect(50, 20, 50, 50))
	.states_([["Go", Color.black, Color.green], ["Stop", Color.black, Color.red]])
	.action_({|v|
		(v.value > 0).if({
			{ startUp.value }.defer;
		}, {
			{ shutDown.value }.defer;
		});
	});
win.front;
CmdPeriod.doOnce({
	sb.do({|e, c|
		e.free;
	});
	sad.free;
	melo.free;
	voc.free;
	win.close;
});
};
)
