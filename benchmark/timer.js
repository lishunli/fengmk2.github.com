var Benchmark = require('benchmark');
var microtime = require('microtime');

var suite = new Benchmark.Suite();

suite
.add('Date.now()', function () {
  var diff1 = Date.now() - Date.now();
})
.add('microtime.now()', function () {
  var diff2 = microtime.now() - microtime.now();
})
.add('process.uptime()', function () {
  var diff3 = process.uptime() - process.uptime();
})
.add('process.hrtime()', function () {
  var t = process.hrtime();
  var diff4 = process.hrtime(t);
})
// add listeners
.on('cycle', function (event, bench) {
  console.log(String(bench));
})
.on('complete', function () {
  console.log('Fastest is ' + this.filter('fastest').pluck('name'));
})
.run();