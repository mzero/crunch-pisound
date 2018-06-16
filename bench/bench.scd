
~bench = Environment.make({ |env|
	env.know = true;

	~xrunFile = "/tmp/xrun";

	~clearXrun = { File.delete(~xrunFile); };
	~hadXrun = { File.exists(~xrunFile); };

	~jackCmd =
	"/usr/bin/jackd -T -R -P 75 -d alsa -d hw:pisound -r 48000 -p % -n % -s";

	~jackRun = { arg jackArgs, task;
		var cmd = ~jackCmd.format(*jackArgs);
		var x =  "running jackd with: %".format(cmd).postln;

		var jackPipe = Pipe.new("./runjack.sh %".format(cmd), "w");
		2.wait;
		task.value;
		jackPipe.close();
		2.wait;
	};

	~serverRun = { arg task;
		// Have to do this all ourselves because Server.waitForBoot doesn't really
		// implement the onFailure: feature!

		var tStart = thisThread.seconds;

		if (s.serverRunning) {
			s.quit;
		};
		s.boot;

		while { s.serverRunning.not && ((thisThread.seconds - tStart) < 5) } {
			0.1.wait;
		};
		if (s.serverRunning)
		{
			var recFile;

			s.recChannels = 2;
			s.record;
			s.sync;

			task.value();

			recFile = s.recorder.path;
			s.stopRecording;
			File.delete(recFile);

			s.quit();
		}
		{
			"Server didn't boot".postln;
		};
	};

	~doDef = {
		SynthDef("BenchTone", {
			// nods to PolyPerc from norns
			arg freq=440, amp=1.0, dur=1.0;
			var base = Pulse.ar(freq, 0.20);
			var env = Env.perc(0.01, dur-0.01, amp).kr();
			var filt = MoogFF.ar(base*env, freq*1.25);

			Out.ar(0, filt.dup);
		}).add;

		s.sync;
	};

	~freqs = (20.collect { |i|
		[1, 4/3, 5/3, 9/4, 5/2]*220 + (i/4);
	}).reshape(100);

	~playN = { arg n;
		var amp = 1/n;
		var dur = 1/3;
		var g = Group.new();

		16.do {
			n.do { |i|
				Synth(\BenchTone, [\freq, ~freqs.wrapAt(i), \amp, amp, \dur, dur], g);
			};

			dur.wait;
			g.freeAll;
		};

		g.free;
		s.sync;
	};

	~testPlayN = { arg n;
		var good;
		"going to play % BenchTones...".format(n).post;
		~clearXrun.value;
		~playN.value(n);
		2.wait;
		good = ~hadXrun.value.not;
		if (good)
			{ "good.".postln; }
			{ "xrun!".postln; };
		good
	};

	~scout = {
		Interval(5, 125, 10).do { |n| ~testPlayN.value(n); };
	};


	~hunt = {
		var lo, mid, hi, good;

		lo = 0;
		hi = 50;
		{ ~testPlayN.value(hi) }.while {
			lo = hi;
			hi = 2 * hi;
		};

		{ mid = ((lo + hi)/2).floor; lo < mid }.while {
			if (~testPlayN.value(mid))
				{ lo = mid; }
				{ hi = mid; };
		};

		"Max voices without xruns: %".format(mid).postln;
		mid
	};

	~test = {
		~serverRun.value( {
			~doDef.value;
			~scout.value;
		});
	};

	~test2 = {
		~jackRun.value( [64, 2], {
			~serverRun.value( {
				~doDef.value;
				~hunt.value;
			});
		});
	};

	~test3 = {
		var results = Dictionary.new;
		[64, 128, 256, 512, 1024].do { |b|
			var counts = 3.collect {
				var count;
				~jackRun.value( [b, 2], {
					~serverRun.value( {
						~doDef.value;
						count = ~hunt.value;
					});
				});
				count
			};
			results.put(b, counts);
		};

		results.keys.asSortedList.do { |k|
			var counts = results.at(k);
			var average = (counts.sum) / (counts.size);
			"% ==> % voices, %".format(k, average.round, counts).postln;
		};
	};


});

nil

