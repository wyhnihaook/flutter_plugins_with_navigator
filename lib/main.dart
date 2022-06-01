import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/util/cache_helper.dart';
import 'package:flutter_plugins_with_componentization/util/navigator_helper.dart';
import 'package:flutter_plugins_with_componentization/util/pre_init.dart';
import 'package:flutter_plugins_with_componentization/util/route_helper.dart';


void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final MyRouterDelegate _delegate = MyRouterDelegate();


  _AppState();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PreInit.preLoad(), //当前异步提前初始化,初始化SDK等操作，执行完毕之后，才会渲染页面
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //注入路由代理信息
          //判断是否在初始化加载中，不然内嵌Router会初始化多次
          bool isLoadDown = snapshot.connectionState == ConnectionState.done;
          print("开始构建当前页面 是否异步任务完毕 $isLoadDown");

          var widget =isLoadDown? Router(routerDelegate: _delegate):
          const Text('loading');

          //普通移动端构建使用的MaterialApp；如果采用网页版本，需要使用MaterialApp.router的构造函数，默认其中必须传递网址url监听变化的routeInformationParser
          //参考main.web.dart文件

          //返回构建的页面信息
          return MaterialApp(
              home: widget, theme: ThemeData(primarySwatch: Colors.blue));
        });
  }
}

///navigator2.0配置路由信息
///要使用路由配置，所有的页面必须在Page的实现类包裹中展示

//路由委托代理
class MyRouterDelegate extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {

  //默认当前展示路由为首页
  RoutePageType _routePageType = RoutePageType.home;

  //手动声明替换自动填充的对象初始化，为了初始化时实现静态方法模块
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  //可以通过navigatorKey.currentState来获取NavigatorState对象
  //通过操作NavigatorState可以 跳转/返回上一页/能否返回上一页等功能
  MyRouterDelegate() :navigatorKey = GlobalKey<NavigatorState>() {
    //初始化时，处理静态代码块，实现当前的跳转封装方法回调
    NavigatorHelper.getInstance().registerRouteListener(
        RouteListener(onJumpTo: (RoutePageType routePageType,{Map? args}){
          //同步当前的路由信息
          //跳转方法实现

          _routePageType = routePageType;
          //首先获取当前路由的基本属性信息
          PageAttribute pageAttribute = _routePageType.pageAttribute;

          switch(pageAttribute.launchMode){
            case LaunchMode.standard:
            //直接将新增的页面添加
              _pages.add(pageWrap(getPage(_routePageType,arguments: args)));
              break;
            case LaunchMode.singleTask:
              int index = getPageIndex(_pages,_routePageType);

              if(index < 0){
                //不存在情况，不做处理
              }else if(index == 0){
                //第一个角标，全部移除，重新添加
                _pages.clear();
              }else if(index == _pages.length - 1){
                //存在最后一个，移除最后一个
                _pages.removeLast();
              }else{
                //移除之前的数据，包括头，不包括尾，当前过滤需要包括自己
                _pages = _pages.sublist(0,index);
              }

              //压入栈顶
              _pages.add(pageWrap(getPage(_routePageType,arguments: args)));

              break;
            case LaunchMode.singleInstance:
            //首先获取当前的存在的页面index，然后删除之前的所有页面
              int index = getPageIndex(_pages,_routePageType);

              if(index < 0){
                //不存在的情况，压入栈顶
                _pages.add(pageWrap(getPage(_routePageType,arguments: args)));
              }else if(index == _pages.length - 1){
                //当前是最后一个页面，不做处理
              }else{
                //移除之前的数据，包括头，不包括尾，当前过滤需要包括自己
                _pages = _pages.sublist(0,index+1);
              }

              break;
            case LaunchMode.singleMainTop:
              //存在的情况，移除之前的页面
              //不存在的情况，移除所有，添加一个新的页面，保证需要显示的当前负载是最顶层页面
              int index = getPageIndex(_pages,_routePageType);

              if(index < 0){
                _pages.clear();
                _pages.add(pageWrap(getPage(_routePageType,arguments: args)));
              }else if(index == _pages.length - 1){
                //当前是最后一个页面，不做处理
              }else{
                //移除之前的数据，包括头，不包括尾，当前过滤需要包括自己
                _pages = _pages.sublist(0,index+1);
              }
              break;
          }
          //这个时候必须保证渲染的数据已经修改完毕<_pages列表整改完毕>

          //刷新当前build方法，根据当前的页面的启动模式进行路由栈的处理
          notifyListeners();
        }));
  }

  // @override
  // GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();


  //声明当前路由的Page集合，开发者需要自己维护的路由的堆栈
  //定义的是当前的堆栈，0,1,2,3角标越大，就越在堆栈的上面，所以后面的页面将显示在前面
  List<MaterialPage> _pages = [];

  @override
  Widget build(BuildContext context) {

    //手动添加首页信息，初始化的时候
    //在这里可以判断当前用户是否登录，如果登录，就跳转到首页。否则跳转到登录页面
    //这里需要用到缓存信息，登录后将缓存信息存在本地，然后再次打开先加载缓存数据，加载完毕之后再进行当前内容的渲染

    //这里一定是异步初始化sdk完成
    //获取当前数据，只有是空的时候。表示第一次渲染，需要手动判断当前页面信息
    if(_pages.isEmpty){
      Object? token = CacheHelper.getInstance().get("token");
      if(token==null||(token as String).isEmpty){
        //跳转登录页
        _pages = [pageWrap(getPage(RoutePageType.login))];
      }else{
        //跳转首页
        _pages = [pageWrap(getPage(RoutePageType.home))];
      }
    }

    print(_pages);
    //当前构建导航器
    return  Navigator(
      key: navigatorKey, //同步当前操作路由的key
      pages: List.of(_pages), //当前路由的Page对象集合
      onPopPage: (route, result) {
        //返回功能处理
        //是否能返回上一页，进行截断 false：返回无效 true：能正常返回
        if (!route.didPop(result)) {
          return false;
        } else {
          return true;
        }
      },
    );
  }


  //setNewRoutePath则是直接修改url或者使用浏览器后退、前进时触发的函数

  //web专用回调方法，初始化url完整链接
  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) async {

  }
//ChangeNotifier 修改路由状态
//PopNavigatorRouterDelegateMixin 复用当前的popRoute功能


}



