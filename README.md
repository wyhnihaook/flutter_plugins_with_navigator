# flutter_plugins_with_navigator
Flutter路由封装  
本文中针对的是Flutter navigator2.0进行架构

## main.dart
运行移动端的入口文件  
通过命令行：flutter run  
相对于navigator1.0，将路由显示的暴露给开发者进行维护，整个路由栈都由当前用户进行迭代  
由此衍生出概念性的启动模式，详见：lib/util/route_helper.dart文件  

## main.web.dart
运行web端的入口文件  
通过命令行：flutter run -t lib/main.web.dart -d chrome  
相对移动端的路由控制基础上，还需要控制网址url上的显示，需要使用MaterialApp.router的构造函数进行实现  
实现了url切换的监听以及参数传递时同步url信息的处理
（基本实现逻辑与main.dart基本一致，新增的方法大多是用来根据url的路径进行快捷跳转的适配）

## 扩展
本文还对初始化sdk的类做了统一管理，通过FutureBuilder进行控制，在异步处理完毕之后才正式加载界面信息<预加载sdk>
（详见：lib/util/pre_init.dart）

## 使用注意点：
对于新增的页面，路由信息必须在lib/util/route_helper中进行声明
查找注释@Iteration must be implemented 并在对应的方法中进行添加新增的页面

## 模拟生命周期onResume和onPause回调
onResume：只在页面隐藏再显示后回调  
onPause：只在页面隐藏后回调  
如果想在初始化就执行类似onResume的回调，可以进行封装，在initState函数中进行初始化执行  
普通生命周期监听参考：home_page.dart文件  
带tab滑动的生命周期监听参考：message_page.dart文件  
注意：需要严格按照参考文件模式实现
