# alimovie

![logo](http://gitlab.alibaba-inc.com/edp/alimovie/blob/master/logo.png)

阿里电影公司管理系统, [http://alimovie.alibaba-inc.com/](http://alimovie.alibaba-inc.com/)


## 联系

* 开发，运维: [@苏千](http://work.alibaba-inc.com/work/u/43624)
* Bug: [http://gitlab.alibaba-inc.com/edp/alimovie/issues](http://gitlab.alibaba-inc.com/edp/alimovie/issues)

---

## 权限说明

按电影角色划分:

* 制片人(admin): 即系统管理员
    - 创建和维护电影季(season)
    - 指定当季导演
    - 给当季剧目打分
    - 修改剧目导演，剧目信息(填充历史数据场景使用)
* 导演(diretor): 剧目负责人
    - 创建剧目(movie)，维护剧目信息
    - 维护剧目成员(movie_member)
    - 分配当季剧目所得分数(star)
* 演员(actor): 剧组成员，所有人都具有的基本角色
    - 上传文件(file)
    - 编辑个人信息(profile)
    - 提交剧目 Issues

---

## 使用说明

### 创建和编辑电影季 season 信息

制片人(admin) 能创建和编辑电影季(season)

![1](http://nfs.nodeblog.org/7/b/7b59358ec1b055b06caba1ab5cd264a0.png)

---

### 任意长文本内容，都是基于 Markdown 格式的

![2](http://nfs.nodeblog.org/e/4/e4e89cac8d3960a07e7b4d1ed07cc391.png)

---

### 编辑页面有离开当前页面提醒

![3](http://nfs.nodeblog.org/c/2/c2ecf759b44382c3e98026d16193808c.png)

---

### 制片人还需要负责添加当季导演

![4](http://nfs.nodeblog.org/9/4/9416d0b4479a76e8282c0b68882cd9f4.png)

---

### 当季剧目列表

![4.1](http://nfs.nodeblog.org/6/3/6338994e84a6106f718c0c5b52fa985c.png)

---

### 当季演员列表

![4.2](http://nfs.nodeblog.org/a/4/a4cd52853d8bad14ddc1e75181c88146.png)

---

### 导演创建和维护剧目(movie)

当季具有导演角色的人，都可以创建剧目

![5](http://nfs.nodeblog.org/9/f/9fcba863f3554e35c7e9ef3d1547541e.png)

---

### 支持绑定 Gitlab 项目

![6](http://nfs.nodeblog.org/c/d/cdabba93ebbf27e93a7879a6d95abe11.png)

---

### 支持自动导入上季延续剧目信息

![7](http://nfs.nodeblog.org/5/9/59d6c77c24328d015f77636715eace79.png)

---

### 剧目文件上传(file)

![8](http://nfs.nodeblog.org/1/4/14f996b19c186ca52211367906c3a1d2.png)

---

### 剧组成员维护

![9](http://nfs.nodeblog.org/9/b/9b807ab6024c91ea61cb4c06f14dbec9.png)

---

### 时光机(历史电影季列表 season list)

![10](http://nfs.nodeblog.org/d/9/d94f03bc8ce6304c4f69da3889978d80.png)

---

### 星光大道(演员全剧目统计)

![11](http://nfs.nodeblog.org/d/2/d26cbf881b51313204755bbe44df0e3f.png)

---

### 个人信息维护页面

目前支持自定义头像

![12](http://nfs.nodeblog.org/3/8/38850c6358d52dc1706e505bfb8b06d2.png)
