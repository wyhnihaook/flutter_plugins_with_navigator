///描述:网页入口 todo 有其他问题需要处理
///功能介绍:Web路由信息处理
///创建者:翁益亨
///创建日期:2022/5/31 18:25
import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/util/cache_helper.dart';
import 'package:flutter_plugins_with_componentization/util/navigator_helper.dart';
import 'package:flutter_plugins_with_componentization/util/pre_init.dart';
import 'package:flutter_plugins_with_componentization/util/route_helper.dart';

///执行运行命令运行web环境的配置路由文件：flutter run -t lib/main.web.dart -d chrome
///目前暂时不做整合，避免路由一些交互的不同造成代码复杂性的提高

///********如果要兼容多个平台的运行，当前sdk的选型特别重要，必须要兼容全部的运行平台*********
///目前不做兼容性处理，只做路由相关展示

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

  //web支持添加依赖
  final MyRouterInformationParser _parser = MyRouterInformationParser();

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

          //返回构建的页面信息
          return MaterialApp.router(
              routerDelegate: _delegate,
              routeInformationParser: _parser,
              routeInformationProvider: PlatformRouteInformationProvider(
                initialRouteInformation:
                    const RouteInformation(location: '/login'),
              ),
              theme: ThemeData(primarySwatch: Colors.blue));
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
  MyRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    //初始化时，处理静态代码块，实现当前的跳转封装方法回调
    NavigatorHelper.getInstance().registerRouteListener(
        RouteListener(onJumpTo: (RoutePageType routePageType, {Map? args}) {
      //同步当前的路由信息
      //跳转方法实现

      _routePageType = routePageType;
      //首先获取当前路由的基本属性信息
      PageAttribute pageAttribute = _routePageType.pageAttribute;

      switch (pageAttribute.launchMode) {
        case LaunchMode.standard:
          //直接将新增的页面添加
          _pages
              .add(pageWrap(getPage(_routePageType,arguments: args), name: _routePageType.url,args: args));
          break;
        case LaunchMode.singleTask:
          int index = getPageIndex(_pages, _routePageType);

          if (index < 0) {
            //不存在情况，不做处理
          } else if (index == 0) {
            //第一个角标，全部移除，重新添加
            _pages.clear();
          } else if (index == _pages.length - 1) {
            //存在最后一个，移除最后一个
            _pages.removeLast();
          } else {
            //移除之前的数据，包括头，不包括尾，当前过滤需要包括自己
            _pages = _pages.sublist(0, index);
          }

          //压入栈顶
          _pages
              .add(pageWrap(getPage(_routePageType,arguments: args), name: _routePageType.url,args: args));

          break;
        case LaunchMode.singleInstance:
          //首先获取当前的存在的页面index，然后删除之前的所有页面
          int index = getPageIndex(_pages, _routePageType);

          if (index < 0) {
            //不存在的情况，压入栈顶
            _pages.add(
                pageWrap(getPage(_routePageType,arguments: args), name: _routePageType.url,args: args));
          } else if (index == _pages.length - 1) {
            //当前是最后一个页面，不做处理
          } else {
            //移除之前的数据，包括头，不包括尾，当前过滤需要包括自己
            _pages = _pages.sublist(0, index + 1);
          }

          break;
        case LaunchMode.singleMainTop:
          //存在的情况，移除之前的页面
          //不存在的情况，移除所有，添加一个新的页面，保证需要显示的当前负载是最顶层页面
          int index = getPageIndex(_pages, _routePageType);

          if (index < 0) {
            _pages.clear();
            _pages.add(
                pageWrap(getPage(_routePageType,arguments: args), name: _routePageType.url,args: args));
          } else if (index == _pages.length - 1) {
            //当前是最后一个页面，不做处理
          } else {
            //移除之前的数据，包括头，不包括尾，当前过滤需要包括自己
            _pages = _pages.sublist(0, index + 1);
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
    if (_pages.isEmpty) {
      Object? token = CacheHelper.getInstance().get("token");
      if (token == null || (token as String).isEmpty) {
        //跳转登录页
        _pages = [
          pageWrap(getPage(RoutePageType.login), name: _routePageType.url)
        ];
      } else {
        //跳转首页
        _pages = [
          pageWrap(getPage(RoutePageType.home), name: _routePageType.url)
        ];
      }
    }

    print(_pages);
    //当前构建导航器
    return Navigator(
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

  //该类很关键，是web中的配置的路由信息同步，一定要实现，空数据一定要返回null，返回[]数组会报错，没有element
  @override
  List<Page>? get currentConfiguration =>
      List.of(_pages).isEmpty ? null : List.of(_pages);

  //web专用回调方法，初始化url完整链接
  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) async {
    //同步新的路由信息
    //将pages进行重新定义
    //这里只要实现当前页面的跳转即可，当前不做赘述，可以理解为onJumpTo回调的简单版本
    //如果要额外维护web的路由，需要额外处理其他情况

    for (int i = 0; i < configuration.length; i++) {
      print("setNew路由信息 ${configuration[i].name}   ${configuration[i].arguments}");
    }

    //一般来说走到这里是第一次或者是刷新当前页面重新渲染或者是url输入回车重定向，这个时候必须要理清楚层级关系
    //通过MyRouterInformationParser->parseRouteInformation方法中做解析返回到该方法处理

    //当前只适配最后一个页面的参数，不关心之前的数据信息

    _pages.clear();
    _pages.addAll(configuration
        .map((routeSettings) => pageWrap(
            //这里要添加最后面一个数据的参数内容
            getPage(getRoutePageType(routeSettings.name!),arguments: routeSettings.arguments!=null?(routeSettings.arguments as Map):{}),
            name: routeSettings.name,args: routeSettings.arguments))
        .toList());


    if (_pages.first.name != '/') {
      // _pages.insert(0, _createPage(const RouteSettings(name: '/')));
    }
    notifyListeners();

    return Future.value(null);
  }
//ChangeNotifier 修改路由状态
//PopNavigatorRouterDelegateMixin 复用当前的popRoute功能

}

//web路由相关,泛型为当前路由信息
//对于web以下的流程
//RouteInformationParser -> RouteDelegate <1.build 2.setNewRoutePath 3.build...>
//当前返回List<RouteSettings>可以用来表明当前网页的嵌套层级接口
class MyRouterInformationParser
    extends RouteInformationParser<List<RouteSettings>> {
  //解析网页中的路由信息，返回当前需要渲染的路由内容
  //也就是按下回车键的时候，会解析url路径信息，setNewRoutePath处理路由栈中的数据，最后通过restoreRouteInformation进行完整路径的同步（网址路径定义完成）
  @override
  Future<List<RouteSettings>> parseRouteInformation(
      RouteInformation routeInformation) async {
    print("parse info location ${routeInformation.location}");
    final uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.isEmpty) {
      return Future.value([const RouteSettings(name: '/home')]);
    }

    //根据/分割数据，获取当前的层级关系用于setNewRoutePath方法中添加路由栈的数据
    final routeSettings = uri.pathSegments
        .map((path) => RouteSettings(
              name: '/$path',
              arguments:
                  path == uri.pathSegments.last ? uri.queryParameters : null,
            ))
        .toList();

    for (RouteSettings routeSettings in routeSettings) {
      print("重定向parser遍历： ${routeSettings.name}");
    }
    return Future.value(routeSettings);
  }

  //每次点击路由信息修改《路由栈修改notifyListeners方法执行后》都会走下面的方法，需要将路由栈被转化为对于的url
  //因为这里的configuration关联的delegate中的currentConfiguration，所以其中一旦更改就会走这里处理 会反向解析MaterialPage中数据维护成一个RouteSettings数据,可以Page继承RouteSettings，所以可以转化
  //根据parseRouteInformation中转化处理后同步浏览器网址的url地址
  @override
  RouteInformation restoreRouteInformation(List<RouteSettings> configuration) {
    //对应的页面转url，跳转当前页面即可

    //最后的重定向要使用全路径回拼
    String location = "";

    //这里必须将url做划分，避免重复嵌套的问题
    for (RouteSettings routeSetting in configuration) {
      print("重定向遍历： ${routeSetting.name}");

      //使用路由信息进行拼接
      location = location + routeSetting.name!;
    }

    //这里要做区分，一条路由数据产生分歧之后的参数拼接

    //还需要显示的参数在后缀拼接
    location = location + resolveUrlLinks(configuration.last);

    return RouteInformation(location: location);
  }

  //将当前携带的参数进行解析，拼接到url链接上，默认需要解析
  String resolveUrlLinks(RouteSettings routeSettings, {bool needResolve = true}) {

    if(!needResolve||(routeSettings.arguments == null)){
      return "";
    }

    var args = routeSettings.arguments as Map;

    //遍历当前的数据内容，进行拼接返回
    String params = "";

    args.forEach((key, value) {
      params= "$params${params.isEmpty?"":"&"}$key=$value";
    });

    print("params $params");
    return params.isEmpty?"":"?$params";
  }
}
