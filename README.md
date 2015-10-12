# mruby-mrack
Rack-like multithreaded web server for MRuby

Currently only opens a thread per socket. Should use a thread per request eventually.

I'm using this for a small rest API served from a raspberry pi.

Requires the [mruby-apr](http://github.com/jbreeden/mruby-apr) gem.
