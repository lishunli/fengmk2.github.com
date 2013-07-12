# Node HBase Client

Asynchronous HBase client for Node.

---

## 为什么要做

### * 目前的性能无法满足(主要原因)
### * 历史遗留的难点
### * 全堆栈的 Node 应用
### * [node-mysql](https://github.com/felixge/node-mysql) 先行者案例: [Faster than C](https://github.com/felixge/faster-than-c)

---

## 怎么做

### * 1人完成最初版本，从 HBase Java Client 源代码入手
### * 搭建 HBase 测试环境 http://abloz.com/hbase/book.html
### * 看到 Java 源代码实现
### * 尽量在2周内完成 hello world 版本

---

## 如果做成了

### * 我们会更加了解 HBase
### * 证明 Node 的方案依然有效
### * KV 存储性能不再是问题
### * Node 直连 HBase 集群, 减少中间节点, 性能会有很大提高
### * 直接开源，让所有感兴趣的开发者来共同开发, 尽量能跟上官方版本更新

---

## [node-hbase-client](https://github.com/TBEDP/node-hbase-client)

### Asynchronous HBase client for Node, pure javascript implementation.

### 纯 Javascript 实现的异步 HBase Client.

![logo](https://raw.github.com/TBEDP/node-hbase-client/master/logo.png)

### * Current State: Only test on Hbase 0.94.0
### * jscoverage: [84%](http://fengmk2.github.io/coverage/node-hbase-client.html)


## Installation

```bash
$ npm install hbase-client
```

---

## 里程碑 `0.1.0` 的 issues 全部完成

![milestone0.1.0](http://nfs.nodeblog.org/4/1/418ead54f57827ac3e627c26b7c61877.png)

---

## 先睹为快

先看看最常用的 `get()` 和 `put()`

### * `create`(options) // 创建客户端, 连接 HBase 集群
### * `get`(table, get, callback)
### * `getRow`(table, rowkey, columns, callback) // 便捷方法
### * `put`(table, put, callback)
### * `putRow`(table, rowkey, data, callback)    // 便捷方法

---

## create(options)

### 通过 ZooKeeper 连接 HBase

```js
var HBase = require('hbase-client');

var client = HBase.create({
  zookeeperHosts: [
    'node1.zk:2181', 'node2.zk:2181',
  ],
  zookeeperRoot: '/hbase-0.94',
});
```

---

## get(table, get, callback)

### 获取一行数据

```js
// Get `f1:name, f2:age` from `user` table.
var get = new HBase.Get('this is a row key');
get.addColumn('f1', 'name');
get.addColumn('f1', 'age');

client.get('user', get, function (err, result) {
  // ... handle err ...
  var kvs = result.raw();
  for (var i = 0; i < kvs.length; i++) {
    var kv = kvs[i];
    console.log('key: `%s`, value: `%s`', kv.toString(), kv.getValue().toString());
  }
});
```

---

## getRow(table, rowkey, columns, callback)

### 为 `get` 提供了更加简便的方法

```js
var row = 'this is a row key';
client.getRow(table, row, ['f:name', 'f:age'], function (err, r) {
// ... handle err ...
  r.should.have.keys('f:name', 'f:age');
});
```

---

## put(table, put, callback)

### 保存数据

```js
var put = new HBase.Put('this is a row key');
put.add('f1', 'name', 'foo');
put.add('f1', 'age', '18');
client.put('user', put, function (err) {
  console.log(err);
});
```

### 为 `put` 提供了更加简便的方法

```js
var row = 'this is a row key';
client.putRow(table, row, {'f1:name': 'foo name', 'f1:age': '18'}, function (err) {
  should.not.exists(err);
});
```

---

## 如何实现的?

# Java 序列化到 Node

---

## Client Server 通信图

### [communication.txt](https://github.com/TBEDP/node-hbase-client/blob/master/communication.txt)

![communication](http://nfs.nodeblog.org/f/2/f274a0f5c3846443f6855276d59f4332.png)

---

## HBase RPC API

### [RegionInterface.java](https://github.com/apache/hbase/blob/0.94/src/main/java/org/apache/hadoop/hbase/ipc/HRegionInterface.java): 所有的 API 都在此接口文件定义 (C++的头文件?!)

```java
  /**
   * Perform Get operation.
   * @param regionName name of region to get from
   * @param get Get operation
   * @return Result
   * @throws IOException e
   */
  public Result get(byte [] regionName, Get get) throws IOException;

  /**
   * Put data into the specified region
   * @param regionName region name
   * @param put the data to be put
   * @throws IOException e
   */
  public void put(final byte [] regionName, final Put put) throws IOException;
```

### 此接口文件声明了服务器端所有可以被调用的接口

---

## Java 对象序列化

### Writable: 所有传输的数据对象，都实现了此接口

```java
public interface Writable {
  /** 
   * Serialize the fields of this object to <code>out</code>.
   * 
   * @param out <code>DataOuput</code> to serialize this object into.
   * @throws IOException
   */
  void write(DataOutput out) throws IOException;

  /** 
   * Deserialize the fields of this object from <code>in</code>.  
   * 
   * <p>For efficiency, implementations should attempt to re-use storage in the 
   * existing object where possible.</p>
   * 
   * @param in <code>DataInput</code> to deseriablize this object from.
   * @throws IOException
   */
  void readFields(DataInput in) throws IOException;
}
```

---

## Get, Put, Scan

### Node 版本设计遵循这个约定，实现 `write` 和 `readFields`:

```js
Get.prototype.write = function (out) {
  out.writeByte(GET_VERSION);
  Bytes.writeByteArray(out, this.row);
  out.writeLong(this.lockId);
  // ... 此处省略
};

Get.prototype.readFields = function (io) {
  var version = io.readByte();
  if (version > GET_VERSION) {
    throw new IOException("unsupported version: " + version);
  }
  this.version = version;
  // ... 此处省略
};
```

---

## 序列化: DataOutputStream

### 封装了一些 Java 基本类型的序列化: boolean, short, byte, char, long, string

* writeByte(v)
* writeBoolean(v)
* writeShort(v)
* writeChar(v)
* writeInt(v)
* writeLong(v)
* ...

---

## `writeLong` 举例

### Java 实现

```java
public final void writeLong(long v) throws IOException {
  writeBuffer[0] = (byte)(v >>> 56);
  writeBuffer[1] = (byte)(v >>> 48);
  writeBuffer[2] = (byte)(v >>> 40);
  writeBuffer[3] = (byte)(v >>> 32);
  writeBuffer[4] = (byte)(v >>> 24);
  writeBuffer[5] = (byte)(v >>> 16);
  writeBuffer[6] = (byte)(v >>>  8);
  writeBuffer[7] = (byte)(v >>>  0);
  out.write(writeBuffer, 0, 8);
}
```

### Node 实现

```js
DataOutputStream.prototype.writeLong = function (v) {
  var buf = new Buffer(8);
  var longV = exports.toLong(v);
  buf.writeInt32BE(longV.high, 0);
  buf.writeInt32BE(longV.low, 4);
  this.write(buf);
};
```

---

# 怎么判断序列化结果正确性?

---

## 100% 对比测试，保证正确性

### 使用 `Java Client` 代码生成将序列化数据保存到文件中

![eclipse](http://nfs.nodeblog.org/8/0/808f336cf7fc8bba46a3da59313ee4aa.png)

---

## 将 Node 序列化结果与这些文件的数据进行对比测试

![nodejs](http://nfs.nodeblog.org/3/8/38a9f593b9fe7e01027741d3d5020242.png)

---

## 测试保证 Node 序列化跟 Java 序列化完全一致

```js
var testJavaBytes = utils.createTestBytes('get');
var cases = [
  // family, qualifier, row, maxVersions
  // 对比 write_f_history_1_0f48MDAwMDAwMDAwMDAwMDAwMA==.java.bytes
  ['f', 'history', '0f48MDAwMDAwMDAwMDAwMDAwMA==', 1],
  // 对比 write_f_history_100_中文rowkey.java.bytes
  ['f', 'history', '中文rowkey', 100],
  // ... other values
];

describe('write()', function () {
  it('should convert Get to bytes', function () {
    for (var i = 0; i < cases.length; i++) {
      var item = cases[i];
      var row = item[2];
      var family = item[0];
      var qualifier = item[1];
      var maxVersions = item[3];
      var get = new Get(row);
      get.addColumn(family, qualifier);
      get.setMaxVersions(maxVersions)
      var out = new DataOutputBuffer();
      get.write(out);
      var bytes = out.getData();
      bytes.length.should.above(0);
      testJavaBytes('write_' + family + '_' + qualifier + '_' + maxVersions, 
        row, bytes);
    }
  });
});
```

---

## 对比测试绝对不是简单测试

### 必须覆盖边界值

如对 long 值的序列化测试用例

![long bytes](http://nfs.nodeblog.org/c/2/c235175177669a64283a306fcea315f5)

---

## Javascript 中的整数长度限制

> As of the ECMAScript specification, number types have a maximum value of 2^53.

### 那么对超过53位的整数进行操作, 会怎样呢?

---

## 超过53位的神奇整数

```js
> Math.pow(2, 53)
9007199254740992
> Math.pow(2, 53) + 1
9007199254740992
> Math.pow(2, 53) + 2
9007199254740994
> Math.pow(2, 53) + 3
9007199254740996
> Math.pow(2, 53) + 4
9007199254740996
```

### 厄, 这不是坑人么!?

---

## 到 [NPM](https://npmjs.org/search?q=long) 找找

### 果然是: 没有找不到的, 只有不够好的

![long-npm](http://nfs.nodeblog.org/f/6/f668cbf5ad09e3ee1261a5b5fb329ca6)

---

## [Long.js](https://github.com/dcodeIO/Long.js)

```
$ npm install long
```

```js
var Long = require('long');
var longVal = new Long(0xFFFFFFFF, 0x7FFFFFFF);
longVal.toString();
// '9223372036854775807'

Long.fromNumber(Math.pow(2, 53)).toString()
// '9007199254740992'
Long.fromNumber(Math.pow(2, 53)).add(Long.fromNumber(1)).toString()
// '9007199254740993'
```

### 缺点: 就是必须都是 Long 对象进行操作

---

## 反序列化: DataInputBuffer

### Java

```java
public static long toLong(byte[] bytes, int offset, final int length) {
  long l = 0;
  for (int i = offset; i < offset + length; i++) {
    l <<= 8;
    l ^= bytes[i] & 0xFF;
  }
  return l;
}
```

### Node

```js
exports.toLong = function (v) {
  // buffer must be 8 bytes
  return Long.fromBits(v.readInt32BE(4), v.readInt32BE(0));
};
```

---

## 性能 Benchmark

### hbase-client@0.1.0

[benchmark.js](https://github.com/TBEDP/node-hbase-client/blob/master/benchmark.js)

```bash
$ node benchmark.js $Concurrency
```

```
测试环境: 
* Only one node process, one connection for one region(hostname:port).
* 2 CPUs: Intel(R) Xeon(R) CPU E5520  @ 2.27GHz
```

## 一个进程同时并发10个请求

### * Get: 3649 QPS, RT 2.73ms, 10 Concurrency
### * Put: 3298 QPS, RT 3.02ms, 10 Concurrency

---

## Get 性能

### * Get: 3649 QPS, RT 2.73ms, 10 Concurrency

![2](http://nfs.nodeblog.org/4/f/4fdd7bd9fc560a28eca4503400ae8f60.png)

---

## Put 性能

### * Put: 3298 QPS, RT 3.02ms, 10 Concurrency

![1](http://nfs.nodeblog.org/d/6/d6c0c0f720b91bb51b3ad930e08e90d5.png)

---

## 真实的线上性能对比截图

图片质量打分接口

### 场景: 每次 `mget` 请求 500 行数据

![imageq](http://nfs.nodeblog.org/b/6/b66c974b4d4cf0c6d42ebd513f88af8a)

### rt 从原来的 300ms ~ 700ms 降到 100ms 以内

---

## 后续

### * [0.2.0](https://github.com/TBEDP/node-hbase-client/issues?milestone=2&state=open) 版本发布，将会更加鲁棒性.
### * 支持 `delete`, `multi actions`, `scan` 更多标准接口
### * 完整的 HBase Client 特性

---

## Node 全堆栈应用才算真正完整

### * Application <= [node-mysql](https://github.com/felixge/node-mysql) => MySQL (MyFox, Garuda, OceanBase, RDS)
### * Application <= [ots client](https://github.com/fengmk2/ots) => OTS (HTTP RESTful)
### * Application <= [hbase-client](https://github.com/alibaba/node-hbase-client) => HBase
### * Application <= [node-hsf](gitlab.alibaba-inc.com/node-hsf) => 阿里内部系统服务接口

---

## 演员们(开发者)

### @苏千: 导演 (无 Java 开发经验)
![sq](http://work.alibaba-inc.com/photo/43624.jpg)

### @汤尧: 男主角 (有多年的 Java 开发经验)
![ty](http://work.alibaba-inc.com/photo/33772.jpg)

---

## hbase on NPM

![hbase on npm](http://nfs.nodeblog.org/b/e/be9d97742c5848c33fe41a457cee0c49)

---

# 知乎者也 Q&A
