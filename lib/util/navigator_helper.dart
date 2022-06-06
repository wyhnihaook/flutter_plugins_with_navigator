import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/util/route_helper.dart';

///描述:当前路由帮助类 navigator 2.0专用
///功能介绍:封装了路由操作信息
///创建者:翁益亨
///创建日期:2022/5/30 19:10

///页面跳转统一封装方法，将当前的路由的跳转能力<委托>到文件中的navigator进行跳转
///传递跳转路由类型 + 传递的参数
typedef OnJumpTo = Function(RoutePageType routePageType,{Map args});

///主要用来监听当前界面的状态，目前只兼容在当前窗口的onResume以及在路由栈中不在当前窗口的onPause状态
typedef RouteChangeListener = Function(RoutePageTypeInfo current, RoutePageTypeInfo? pre);

///针对界面返回或者手动切换tab展示的回调信息
typedef RouteAndTabChangeListener = Function(LifeCycle lifeCycle);


//路由信息记录
class RoutePageTypeInfo {
  final RoutePageType routePageType;
  final Widget page;

  RoutePageTypeInfo(this.routePageType, this.page);
}

//抽象类用于同步委托的方法，可扩展路由委托的其他功能，继承实现，用于区分普通的内部方法
abstract class _RouteListener{
  onJumpTo(RoutePageType routePageType,{Map args});
}

//实体类用于传递委托的路由能力，用于存储当前的扩展功能，可扩展路由委托的其他功能
class RouteListener{
  final OnJumpTo? onJumpTo;

  RouteListener({this.onJumpTo});
}


//构建当前路由页面
//其中name用于当前web路由网址显示,args为在网页上构建的传递参数
MaterialPage pageWrap(Widget child,{String? name,Object? args}){
  //添加key属性，保证当前的唯一性
  return MaterialPage(child: child,key: ValueKey(child.hashCode),name: name,arguments: args);
}

///统一封装路由跳转内容
class NavigatorHelper extends _RouteListener{

  //路由帮助类单例实现
  NavigatorHelper._();
  static NavigatorHelper? _instance;
  static NavigatorHelper getInstance(){
    return _instance??=NavigatorHelper._();
  }

  //所有需要被监听路由页面初始化时创建的监听事件
  final List<RouteChangeListener> _listeners = [];

  //用于当前存在Tab情况的子容器中的view信息生命周期回调
  //当前的key规则设定：当前主容器名称-当前子容器名称 ；例如：MessagePage-MainTabPage
  final Map<String,RouteAndTabChangeListener> _subContainerListeners = {};

  //记录当前窗口展示的页面
  RoutePageTypeInfo? _currentPage;

  //当前委托路由信息
  RouteListener? _routeListener;

  //添加监听事件
  void addListener(RouteChangeListener routeChangeListener){
    //不区分是否添加过，只要需要就一直往数组中添加
    _listeners.add(routeChangeListener);
  }

  //页面销毁时需要移除当前监听事件
  void removeListener(RouteChangeListener routeChangeListener){
    if(_listeners.contains(routeChangeListener)){
      _listeners.remove(routeChangeListener);
    }
  }

  //以下事件回调，由父容器下发
  //子容器添加监听回调事件
  void addSubContainerListener(String key,RouteAndTabChangeListener listener){
    //这里不做过滤，默认每个页面不会重复加载
    //将当前的value添加到对应的key中
    _subContainerListeners[key]=(listener);
  }

  //子容器监听删除
  void removeSubContainerListener(String key){
    //移除当前所有子view的监听
    _subContainerListeners.remove(key);
  }

  //存在Tab的情况，单独每个Tab需要响应切换事件
  //切换后将对应的数据内容进行匹配，之前和之后的subContainer的名称
  void notifyTabChange(String mainKey,LifeCycle lifeCycle){

    //当前情况，将数据放置到具体页面层做判断，传递当前的生命周期
    if(_subContainerListeners.containsKey(mainKey)) {
      _subContainerListeners[mainKey]!(lifeCycle);
    }
  }

  //切换时执行的方法封装，切换时会执行当前的onResume和之前选中的onPause回调
  void switchTabChange(String currentKey,String preKey){

    notifyTabChange(currentKey,
        LifeCycle.onResume);

   notifyTabChange(preKey,
        LifeCycle.onPause);
  }

  //需要判断当前路由和之前的路由内容的差距
  void notify(List<MaterialPage> pages,{bool isPop = false}){
    //直接获取最后一个数据进行赋值，最后一个为当前最先展示数据

    if(isPop){
      //移除当前数据
      pages.removeLast();
    }

    var current = RoutePageTypeInfo(getPageType(pages.last),
        pages.last.child);
    _notify(current);
  }

  //添加当前的路由信息
  void _notify(RoutePageTypeInfo current){

    //需要遍历当前监听器进行传递
    //使用当前展示的页面和之前的页面进行监听匹配

    //单页面的情况-->
    //如果current是自己，就走onResume
    //如果_currentPage是自己，就走onPause
    //除此之外都不执行生命周期其他情况
    //////当前植入的是整个路由信息

    //多页面的情况（TabView或PageView）-->
    //其中的监听器添加需要添加到每一个TabView/PageView的页面进行处理
    //类似其中显示与否的状态回调
    //这个时候添加的主页面是相同的，具体的page是不同的
    //////当前植入的是当前的点击事件需要_subContainerListeners调用以及区分当前index的view
    //////注意：有TabView或PageView的在主页面必须进行生命周期监听，因为需要下发给子view

    for (var listener in _listeners) {
      listener(current,_currentPage);
    }

    //同步当前的页面数据
    _currentPage = current;
  }

  //注入当前路由的委托信息，使_routeListener中的方法委托到路由上实现
  void registerRouteListener(RouteListener routeListener){
    _routeListener = routeListener;
  }


  //委托路由实现的跳转方法
  @override
  onJumpTo(RoutePageType routePageType, {Map? args}) {
    //委托到实际实现路由进行跳转页面
    //当前表示_routeListener没有注入时不调用后续方法
    //并且如果已经注入，那么onJumpTo方法一定委托成功，存在委托的方法
    _routeListener?.onJumpTo!(routePageType,args:args??{});
  }

}

///获取当前的页面在路由栈中的index
int getPageIndex(List<MaterialPage> pages,RoutePageType routePageType){

  for(int i=0;i<pages.length;i++){
    MaterialPage materialPage = pages[i];
    if(getPageType(materialPage) == routePageType){
      return i;
    }
  }
  return -1;
}