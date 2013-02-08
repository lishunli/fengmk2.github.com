# 淘宝时光机背后的技术故事

相信大家早已在阿里味看过 [“淘宝时光机”是如何炼成的](http://www.aliway.com/read.php?fid=38&tid=185140) 

本文主要回忆讲讲淘宝时光机所依赖的一些技术和产品。

## 数据

* 第一次翻开封尘的历史交易数据（2003年~2012年），数百TB，2亿用户；
* 对近六个月的买家浏览，成交进行计算，给每月用户打兴趣爱好标签；
* 在 ODPS（Open Data Processing Service）上运行计算，1小时完成对上述数据的计算工作，最终产出400GB数据。
* 具体算法请查看 [“淘宝时光机”是如何炼成的](http://www.aliway.com/read.php?fid=38&tid=185140) 

于是我们有了“上学、毕业、恋爱、结婚、买房”等等人生节点，于是我们知道了“你在淘宝消失了多少天”。

## HBase

按照之前的经验，以Key Value方式获取数据，很自然地我们将400GB的用户数据存储到 10台机器组成的 TCIF HBase。

由于是全量导入数据，一开始的时候竟然遇到无法完全导入的各种状况，后来@天湛 同学逐渐掌握门路，
经过过多次重新计算，重新导入数据的过程，在最后一次导入生产数据花了大概4个小时。

在这期间 @竹庄 提供了新的 [bulk-load](http://baike.corp.taobao.com/index.php/%E4%BA%91%E6%A2%AFHBase%E5%BC%80%E5%8F%91%E6%B5%8B%E8%AF%95%E7%8E%AF%E5%A2%83#.E9.80.9A.E8.BF.87put.E6.96.B9.E5.BC.8F.E8.BF.9B.E8.A1.8Cbulk-load) 导入方式，据说能大大地缩小导入时间，因为项目时间紧，我们最终未使用。

## itier

[itier](http://gitlab.alibaba-inc.com/itier) 是使用 [nodejs](http://nodejs.org) 开发的数据中间层，
封装了对后端各种异构数据源的访问控制逻辑。让使用者以简单的，统一的SQL形式访问任意数据源。

你可以将 itier 想象成一个 "虚拟的MySQL"。目前支持的数据源包括：nodefox(mysql集群)，[iSearch](http://searchwiki.taobao.ali.com/index.php/Category:%E5%BC%95%E6%93%8E%E7%B3%BB%E7%BB%9F-%E4%B8%BB%E6%90%9C%E7%B4%A2)，[HBase](http://hbase.alibaba-inc.com/)，[OTS](http://www.aliyun.com/product/ots/)。

目前[淘宝指数](http://shu.taobao.com)，[数据魔方](http://mofang.taobao.com) 都是通过 itier 获取数据的。

由于 [itier](http://gitlab.alibaba-inc.com/itier) 无法直接使用HBase的客户端对其进行访问，于是我们只能通过中间加一层 [HBaseREST](http://monitor.taobao.com/monitorportal/main/main.htm?confId=1424) 来间接访问HBase。

## Web

Web服务器也是使用nodejs开发的。

Web端在我看来是一个数据枢纽，根据接口的业务逻辑，将各种数据汇聚，然后发送给浏览器。

从我们看到的前端时光机影片，时光星球的动态星空，到Web端数据接口，开发语言统一为Javascript，真正的全堆栈的Javascript数据产品。

人员：时光机开发@米尔，时光星球开发@宁朗。

@米尔 同学特别强调，时光机不是FLASH！！！

## HSF

除了Web接口，我们还以HSF接口方式提供数据给“爱逛街”和“淘宝无线”调用。

同样，我们的HSF模块是基于hsfcpp开发的nodejs版本：[node-hsf](http://gitlab.alibaba-inc.com/node-hsf/tree/master)。

## sessionproxy 与 cookie解密

由于时光机是涉及个人隐私的数据产品，必须保证是登录用户才能看到自己的时光机。

我们之前一直是使用sessionproxy的http接口对sid进行验证。

因为时光机数据接口的性能要求是至少2W qps，按目前sessionproxy集群的性能，是无法满足的。

于是我找到了开发@悟远，并且惊动了不少人。

经过讨论后，我们有了两种选择：

* 直接访问tair获取session
* 直接解密cookie验证

神人@卡特 很快就将访问tair获取session 的路子走通了，
但是由于存储的数据是以Java序列化的，无法确保反序列化出来的数据是否完全正确。

直接解密cookie验证的方式，耗时一个通宵，特别感谢@晓风，@不四，@悟远，@卡特，@汤尧，@继风 的连夜帮忙。

@晓风 在凌晨3点06分发来旺旺：“网上找开源的没找到，手写了一个c版本测试通过”，于是在第二天(12月1日)早上9点半，我们解密成功了。

最后，我们的cookie解密验证的性能达到了单进程 1.3w qps。用户验证不再是瓶颈。

![http://nfs.nodeblog.org/6/9/699b5cbe7946fa5f14961632c9800d74.png](http://nfs.nodeblog.org/6/9/699b5cbe7946fa5f14961632c9800d74.png)

## TFS + 2亿用户分享截图

[TFS](http://baike.corp.taobao.com/index.php/CS_RD/tfs_new) 支撑了我们2亿用户的分享图片存储。

在 @楚玉 的帮忙下，我们快速地开通了TFS的权限。

并在当天晚上，我基于[TFS RESTful](http://baike.corp.taobao.com/index.php/CS_RD/tfs/use_web_service) 开发完成了nodejs版本的[tfs client](http://gitlab.alibaba-inc.com/node-tfs).

同时 @不四 也基于[phantomjs](http://phantomjs.org/)开发完成了分享图片截图。

第二天，我们开始使用TFS的自定义文件名上传接口，以2000qps ~ 3000qps进行截图并上传到TFS。

很快，我们引起了TFS的mysql报警，非常抱歉，大周日的还让TFS的PE@陆离、开发@道安 一阵惊鸿。

在跟@道安 的沟通后，我们放弃了自定义文件名上传，使用随机文件名上传。

之后在整个上传过程中，@陆离 一直陪着我们在观察，我们最终在12月4日早上10点31分，将2亿张(12TB)分享图片全部存储到TFS中。

@不四 为此写的任务调度系统，被大量用于后面的数据预热，数据校验和修正等批量任务中。

![http://nfs.nodeblog.org/2/7/279f018573ca28d113b9409768ad61fd.jpg](http://nfs.nodeblog.org/2/7/279f018573ca28d113b9409768ad61fd.jpg)

## tair

考虑到性能，我们从一开始的方案切换到 Web + tair 的最简单架构。

那么我们就必须有足够大的tair内存来存储所有用户数据。

平均一份用户数据大小为1.5KB。

存储2亿份数据需要 1500 * 200000000 / 1024 / 1024 / 1024 = 279 GB 内存。

为了进一步减少存储空间和网络流量，我们对每份用户数据进行了gzip压缩，整体数据量会减少50%。

gzip 压缩后只需要 279 * 0.5 = 139.5 GB。

感谢tair团队的大力支持，我们通过之前@不四 写的任务调度系统，对2亿用户数据全部预热到tair集群中。

@卡特 还无意地发现tair的第一版比redis还要早半年。

![http://nfs.nodeblog.org/e/f/ef5d0be12824026151592373c1199719.png](http://nfs.nodeblog.org/e/f/ef5d0be12824026151592373c1199719.png)

## 性能测试

性能测试持续了好几天，中途出现了tair单点压测导致tair某节点挂掉；HBaseREST出现异常；Web节点出现内存泄露等等。

最终被我们大家一起努力解决。感谢你们：@仁甫，@火林，@卡特，@陆离，@朋春，@凤吟，@半农，@竹庄，@all。

我们的预期QPS从最早的1W QPS，到最后变成了6W QPS。

我们的整体架构从：web => itier => hbaserest => hbase，变成了最简单的：web => tair。

最终无论itier方案或者tair方案，都能满足性能要求。

![http://nfs.nodeblog.org/e/d/edb61699609366a160a0a61ec41302bc.png](http://nfs.nodeblog.org/e/d/edb61699609366a160a0a61ec41302bc.png)

## 插曲: 有爱的故事

除了技术，时光机能做出来，还因为它里面有爱。

### 1. 借钱

分享图片生成，我们预估了一下需要50台机器，而且还剩下3天了，不可能临时申请到的，怎么办？

没办法，就像没钱了，要去借钱一样，我立马想到的是借机器！

第一个打给@朋春，因为有事找春哥，朋春说“好，没问题，我有4台实体机，4台虚拟机，但是你不能告诉别人是借我的。”

然后想起garuda和它的机器集群，又立马拨通高富帅@离哲，高富帅想了一会，有7台可以临时借用的实体机。“好，我要。”

之后还打个了@清笃，@玄澄，然后让@玄澄 帮忙继续借。。。

然后我们的图片就按时生成完成，中途还因为qps过高，将tfs压得透不过气来。

![http://nfs.nodeblog.org/c/4/c4f15681c241653566613a04adc95e0f.png](http://nfs.nodeblog.org/c/4/c4f15681c241653566613a04adc95e0f.png)

### 2. 雨夜送机

因为我们在创业12楼项目室办公，当晚吃饭前，@米尔 说惨了，我的是MAC，没IE，测试不了。。。

于是我开着玩笑地发了个微博，让EDP的亲们帮忙送机器过来。

没想到他们真的送来了。。。 T_T 那晚下着冷雨，我们看到他们，都感动到要哭了。。。

于是当晚我们很努力地将IE兼容性什么的都搞掂了！

![http://nfs.nodeblog.org/e/3/e3d010bf2ec332b5e342b4c66b96ca99.jpg](http://nfs.nodeblog.org/e/3/e3d010bf2ec332b5e342b4c66b96ca99.jpg)

### 3. 生活在工作中

@宁朗，一个将要结婚的男人，因为要赶着时光星球按时上线，竟然连跟未婚妻第二次恋爱的纪念日给忘记了。。。

他就这样在项目室生活起来了。还好，最后他的未婚妻 被时光机感动了。。。

![http://nfs.nodeblog.org/f/f/ff5ec534db8d3e7607a9701254b8670c.jpg](http://nfs.nodeblog.org/f/f/ff5ec534db8d3e7607a9701254b8670c.jpg)

时光机为什么感动人？因为我们都有爱。

感谢每一位为时光机付出过的，被感动过的，宣传过的，看过的人。

## 1212，我们又如初见

以@米谜 的话结束我们的时光机技术故事：

> 说这么多，其实我心里明白，淘宝时光机能感动人，不是因为产品本身多棒，被感动的人其实是被自己的回忆打动。
>
> 因为我们大多数人对于生活对于过去，总归是心存感恩和怀念的。
>
> 创意、文案、数据、开发、设计失去了任何一环，我们这个小团队里失去了任何一个人。
> 
> 我觉得淘宝时光机都不会是这个样子。

![http://ww1.sinaimg.cn/large/6c14dfa4jw1dzrxrpt5mej.jpg](http://ww1.sinaimg.cn/large/6c14dfa4jw1dzrxrpt5mej.jpg)