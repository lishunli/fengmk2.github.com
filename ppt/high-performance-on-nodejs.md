# Node.js 高性能编程 

High Performance Node.js

---

## Who am I? 我是谁？

### Alibaba Data EDP
### 阿里巴巴数据平台EDP，花名@苏千
### Chinese nodejs community: [cnodejs.org](http://cnodejs.org)

<hr/>

### Github: @[fengmk2](https://github.com/fengmk2/)
### Blog: http://fengmk2.github.com
### Twitter: @fengmk2
### Weibo: @Python发烧友 , @FaWave

> 一切都是最好的安排

---

## 内容大纲

### * Node.js的执行速度
### * 异步, 非阻塞
### * callback 潜规则
### * fs
### * http
### * Stream
### * HSF
### * BDD

---

## Node.js的执行速度

根据 [fibonacci(40) benchmark](http://fengmk2.github.io/blog/2011/fibonacci/nodejs-python-php-ruby-lua.html) 结果

![1](http://nfs.nodeblog.org/5/6/56bf605d0ef507d73426a7c2b5c439d3.png)

---

## Loop 循环

能用 for 的情况下, 就不使用 forEach, 性能实在差异太大: [benchmark/for_forEach.js](http://fengmk2.github.io/benchmark/for_forEach.js)

code | ops/sec 
---  | ---
for (var i = 0; i < datas20.length; i++) | 12,279,015
datas20.forEach() | 581,433
for (var i = 0; i < datas200.length; i++) | 1,740,121
datas200.forEach() | 69,918
for (var i = 0; i < datas500.length; i++) | 730,896
datas500.forEach() | 28,324

```bash
$ node benchmark/for_forEach.js 

for (var i = 0; i < datas20.length; i++) x 12,279,015 ops/sec ±2.04% (86 runs sampled)
datas20.forEach() x 581,433 ops/sec ±2.35% (91 runs sampled)

for (var i = 0; i < datas200.length; i++) x 1,740,121 ops/sec ±0.49% (91 runs sampled)
datas200.forEach() x 69,918 ops/sec ±0.68% (96 runs sampled)

for (var i = 0; i < datas500.length; i++) x 730,896 ops/sec ±0.35% (96 runs sampled)
datas500.forEach() x 28,324 ops/sec ±0.68% (94 runs sampled)

Fastest is for (var i = 0; i < datas20.length; i++)
```

---

## 异步, 非阻塞

### IO的阻塞和非阻塞

![2](http://nfs.nodeblog.org/4/7/4764c351daae7e116c675edb4d97f30d.png)
![3](http://nfs.nodeblog.org/1/0/10298b03dcb7771edaf3577d59a4931f.png)

---

## 异步IO

![4](http://nfs.nodeblog.org/3/4/34ab7f32596b42fce5178a019b93767b.png)

---

## 一切都是异步非阻塞IO

在 Node.js 中, 文件IO和网络IO都是非阻塞的.

![5](http://nfs.nodeblog.org/c/e/cef55da90897424bb178f6e8dac23a67.png)

---

## callback(err, data1[, data2, ...]) 潜规则

### * 异步编程必然会出现callback
### * 统一的callback参数约定
### * go 语言也是类似的约定: 返回值最后一个是err

---

## Node.js: function callback(err, data)

```js
mysql.query(sql, function (err, rows) {
  if (err) {
    logger.error(err);
    // handle error logic
  } else {
    // handle rows
  }
});
```

---

## Go: func Open(name string) (file *File, err error)

[Error handling and Go](http://blog.golang.org/error-handling-and-go)

```go
f, err := os.Open("filename.ext")
if err != nil {
    log.Fatal(err)
}
// do something with the open *File f
```

---

## fs: 只使用异步接口

判断文件是否存在

```js
fs.exists('/etc/passwd', function (exists) {
  console.log(exists ? "it's there" : "no passwd!");
});
```

### 读取配置文体

除了你明确知道不会影响性能的情况下才使用同步方式

```js
var config = fs.readFileSync(__dirname + '/config.ini', 'utf-8');
// covert ini config to js object
```

---

## http Server

### 通常, 都会以最简单的 Hello World 来展示Node.js 写 http server 是如何快速高效的:

```js
var http = require('http');

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
}).listen(1337, "127.0.0.1");

console.log('Server running at http://127.0.0.1:1337/');
```

---

## http hello world benchmark

[http hello world 性能测试大比评]

![http benchmark](http://nfs.nodeblog.org/6/7/67d91334cea275041c662af889a71b57.png)

Node.js的各个版本的: [Nodejs "Hello world" benchmark]

---

## 超时, 网络异常处理

[urllib.js#L211](https://github.com/TBEDP/urllib/blob/master/lib/urllib.js#L211)

```js
  var timeout = args.timeout;
  var __err = null;

  timer = setTimeout(function () {
    timer = null;
    __err = new Error('Request timeout for ' + timeout + 'ms.');
    __err.name = 'RequestTimeoutError';
    req.abort();
  }, timeout);

  req.once('error', function (err) {
    if (!__err && err.name === 'Error') {
      err.name = 'RequestError';
    }
    done(__err || err);
  });
```

---

## Stream: 流式编程

我们常用的 `cat` 命令

```bash
$ cat
Hello
Hello
World
World
```

---

## 使用 Node.js 的 Stream 概念能轻松模拟

```js
process.stdin.pipe(process.stdout);
```

## gzip 压缩一个文件

```js
var r = fs.createReadStream('file.txt');
var z = zlib.createGzip();
var w = fs.createWriteStream('file.txt.gz');
r.pipe(z).pipe(w);
```

## [formstream](https://github.com/fengmk2/formstream) 表单上传文件

```js
var formstream = require('formstream');
var http = require('http');

var form = formstream().file('file', './logo.png', 'upload-logo.png');

var options = {
  method: 'POST',
  host: 'upload.cnodejs.net',
  path: '/store',
  headers: form.headers()
};
var req = http.request(options, function (res) {
  console.log('Status: %s', res.statusCode);
  res.on('data', function (data) {
    console.log(data.toString());
  });
});

form.pipe(req);
```

---

## HSF: 淘宝hsf的node版本

[node-hsf](http://gitlab.alibaba-inc.com/node-hsf/tree/master): 淘宝hsf的node版本，实现了provider和consumer的主要功能。

* 序列化反序列化模块通过C++模块实现
* 网络传输部分node实现。
* 同时在hsf的基础上扩展了node之间互相调用的JSON序列化方式，性能有极大提升。
* 支持Java基本类型和自定义类型

## Node.js 调用 Java HSF 服务

```js
var hsf = require('hsf');
var client = hsf.createClient({
  configSvr: 'config server host',
  // ...
});
// 创建一个consumer，可以同时创建多个consumer来调用多个HSF服务
var testConsumer = client.createConsumer('com.taobao.hsfcpp.service.nodejs', '1.0.0');

// 调用服务端的 plus 方法，第二个参数是调用 plus 方法时的参数数组，相当于调用 plus(3, 4);
testConsumer.invoke('plus', [3, 4], function (err, data) {
  // callback
});
```

## [Benchmark](http://gitlab.alibaba-inc.com/node-hsf/blob/master/benchmark.md)

name | concurrent | qps | rt (ms)
---  | ---        | --- | ---
http hello world | 50 | 9919 | 10
http hello world | 100 | 10856 | 10
hsf ping echo    | 10  | 16200 | 6.16
hsf call (json)  | 10  | 13500 | 7.39
hsf call (hessian) | 10 | 7800 | 12.79

---

## BDD: Benchmark Driven Development

BDD是如何工作的?

### 例如: 我想写世界上最快的函数

```js
function benchmark() {
  // just empty
}
```

---

## 写一个最简单的基准测试来测试它

```js
while (true) {
  var start = Date.now();
  benchmark();
  var duration = Date.now() - start;
  console.log(duration);
}
```

---

## 厄, 它完全没有用啊!

对的, 它就是基准的开始, 我们就在它里面加上我们的代码逻辑

```js
function arrayToObject(arr) {
  var obj = {};
  for (var i = 0; i < arr.length; i++) {
    var item = arr[i];
    obj[item[0]] = item[1];
  }
  return obj;
}
```

然后测试它

```
while (true) {
  var start = Date.now();
  arrayToObject([['foo', 1], ['bar', 2]]);
  var duration = Date.now() - start;
  console.log(duration);
}
```

---

## BDD 的实践证明

[Faster than C? Parsing binary data in JavaScript.], video: [Faster than C? Parsing Node.js Streams!]

### * Performance is not a tool.
### * Performance is hard work & data analysis.

![1](http://nfs.nodeblog.org/5/3/530efa642be76cbde2ad5682b766cdc7.png)

---

# 知乎者也 Q&A

---

## 参考文章

* [Scaling node.js to 100k concurrent connections!]
* [Escape the 1.4GB V8 heap limit in Node.js!]
* [Faster than C? Parsing binary data in JavaScript.]
* [Faster than C? Parsing Node.js Streams!]
* [how to write node programs with streams]
* [http hello world 性能测试大比评]
* [Web Framework Benchmarks]
* [Nodejs "Hello world" benchmark]

[Web Framework Benchmarks]: http://www.techempower.com/benchmarks/
[Scaling node.js to 100k concurrent connections!]: http://blog.caustik.com/2012/04/08/scaling-node-js-to-100k-concurrent-connections/
[Escape the 1.4GB V8 heap limit in Node.js!]: http://blog.caustik.com/2012/04/11/escape-the-1-4gb-v8-heap-limit-in-node-js/
[Faster than C? Parsing binary data in JavaScript.]: https://github.com/felixge/faster-than-c
[Faster than C? Parsing Node.js Streams!]: http://2012.jsconf.eu/speaker/2012/09/05/faster-than-c-parsing-node-js-streams-.html
[how to write node programs with streams]: https://github.com/substack/stream-handbook
[http hello world 性能测试大比评]: https://github.com/onlytiancai/codesnip/blob/master/c/study/2/README.md
[Nodejs "Hello world" benchmark]: http://fengmk2.github.io/blog/helloworld-benchmark.html
