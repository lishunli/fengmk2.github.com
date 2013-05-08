# Node HBase Client

Asynchronous HBase client for nodejs.

---

## 为什么要做

### * 目前的性能无法满足
### * 历史遗留的难点
### * 全堆栈的nodejs链路
### * node-mysql 先行者案例

---

## 怎么做

暂定1人完成最初版本，从源代码入手

### * 搭建HBase测试环境 http://abloz.com/hbase/book.html
### * 看到Java源代码
### * 尽量在2周内完成 hello world 版本

---

## 如果做成了

### * 我们会更加了解HBase
### * nodejs的方案依然有效
### * KV存储性能不再是问题
### * 客户端形式引入服务，减少中间节点
### * 直接开源，让所有感兴趣的开发者来共同开发

---

## [node-hbase-client](https://github.com/TBEDP/node-hbase-client)

### Asynchronous HBase client for nodejs, pure javascript implementation.

### 纯 Javascript 实现的异步 HBase Client.

![logo](https://raw.github.com/TBEDP/node-hbase-client/master/logo.png)

### * Current State: Only test on Hbase 0.94
### * jscoverage: [84%](http://fengmk2.github.io/coverage/node-hbase-client.html)


## Install

```
$ npm install hbase-client
```

---

## 目前里程碑 `0.1.0` 的 issues 全部完成

![milestone0.1.0](http://nfs.nodeblog.org/4/1/418ead54f57827ac3e627c26b7c61877.png)

---

## Usage: `get(table, get, callback)`

### 获取一行数据

```js
var HBase = require('hbase-client');

var client = HBase.create({
  zookeeperHosts: [
    '127.0.0.1:2181', '127.0.0.1:2182',
  ],
  zookeeperRoot: '/hbase-0.94',
});

// Get `f1:name, f2:age` from `user` table.
var param = new HBase.Get('foo');
param.addColumn('f1', 'name');
param.addColumn('f1', 'age');

client.get('user', param, function (err, result) {
  console.log(err);
  var kvs = result.raw();
  for (var i = 0; i < kvs.length; i++) {
    var kv = kvs[i];
    console.log('key: `%s`, value: `%s`', kv.toString(), kv.getValue().toString());
  }
});
```

---

## `getRow(table, rowkey, columns, callback)`

### 提供更加简便的方法

```js
client.getRow(table, row, ['f:name', 'f:age'], function (err, r) {
  r.should.have.keys('f:name', 'f:age');
});
```

---

## `put(table, put, callback)`

### 保存数据

```js
var put = new HBase.Put('foo');
put.add('f1', 'name', 'foo');
put.add('f1', 'age', '18');
client.put('user', put, function (err) {
  console.log(err);
});

client.putRow(table, row, {'f1:name': 'foo name', 'f1:age': '18'}, function (err) {
  should.not.exists(err);
});
```

---

## Client Server 通信图

* [communication.txt](https://github.com/TBEDP/node-hbase-client/blob/master/communication.txt)
* [RegionInterface.java](https://github.com/apache/hbase/blob/0.94/src/main/java/org/apache/hadoop/hbase/ipc/HRegionInterface.java): 所有的API 都在此接口文件定义

![communication](http://nfs.nodeblog.org/f/2/f274a0f5c3846443f6855276d59f4332.png)

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

### nodejs 版本延续这个约定，实现 `write` 和 `readFields`:

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

## DataOutputStream

### 封装了一些基本类型的序列化: int32, short, byte, char, long, string

### `writeLong` 举例

### java

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

### nodejs

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

## 测试，保证正确性

使用 `java client` 代码生成将序列化数据保存到文件中

![eclise](http://nfs.nodeblog.org/8/0/808f336cf7fc8bba46a3da59313ee4aa.png)

---

## nodejs 代码将序列化结果与这些文件的数据进行对比测试

![nodejs](http://nfs.nodeblog.org/3/8/38a9f593b9fe7e01027741d3d5020242.png)

---

## 测试保证nodejs序列化跟java序列化完全一致

```js
var testJavaBytes = utils.createTestBytes('get');
var cases = [
  // family, qualifier, row, maxVersions
  ['f', 'history', '0f48MDAwMDAwMDAwMDAwMDAwMA==', 1],
  ['f', 'history', '2dbbMDAwMDAwMDAwMDAwMTAwMA==', 50],
  ['f', 'history', '中文rowkey', 100],
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

## Long 超过53位的整数

```js
> Math.pow(2, 53)
9007199254740992
> Math.pow(2, 53) + 1
9007199254740992
```

### [Long.js](https://github.com/dcodeIO/Long.js)

```
$ npm install long
```

```js
var Long = require('long');
var longVal = new Long(0xFFFFFFFF, 0x7FFFFFFF);
console.log(longVal.toString());
// 9223372036854775807
```

---

## java <=> nodejs

### java

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

### nodejs

```js
exports.toLong = function (v) {
  // buffer must be 8 bytes
  return Long.fromBits(v.readInt32BE(4), v.readInt32BE(0));
};
```

---

## 性能 Benchmark

hbase-client@0.1.0

[benchmark.js](https://github.com/TBEDP/node-hbase-client/blob/master/benchmark.js)

```bash
$ node benchmark.js $Concurrency
```

**Only one node process, one connection for one region(hostname:port).**

2 CPUs: **Intel(R) Xeon(R) CPU E5520  @ 2.27GHz**

### * Get: 3649 QPS, RT 2.73ms, 10 Concurrency
### * Put: 3298 QPS, RT 3.02ms, 10 Concurrency

---

## Get

### * Get: 3649 QPS, RT 2.73ms, 10 Concurrency

![2](http://nfs.nodeblog.org/4/f/4fdd7bd9fc560a28eca4503400ae8f60.png)

---

## Put

### * Put: 3298 QPS, RT 3.02ms, 10 Concurrency

![1](http://nfs.nodeblog.org/d/6/d6c0c0f720b91bb51b3ad930e08e90d5.png)

---

## 后续

### * [0.2.0](https://github.com/TBEDP/node-hbase-client/issues?milestone=2&state=open) 版本发布，将会更加鲁棒性.
### * 支持 `delete`, `multi actions` 更多标准接口
### * 应用在现有项目中, cubeserach, datapi
### * 应用在 [itier](http://gitlab.alibaba-inc.com/itier) 中，替换到目前的 rest 方式
### * 完整的 HBase Client 特性

---

## 自此，nodejs 全堆栈应用才真正完整

### * nodejs <=> MySQL (myfox, garuda, OceanBase)
### * nodejs <=> OTS (HTTP RESTful)
### * nodejs <=> HBase

---

## 演员们

### @苏千: 导演
![sq](http://work.alibaba-inc.com/photo/43624.jpg)

### @汤尧: 跑龙套
![ty](http://work.alibaba-inc.com/photo/33772.jpg)

### @凤吟: 跑龙套
![fy](http://work.alibaba-inc.com/photo/58803.jpg)

---

# 知乎者也 Q&A
