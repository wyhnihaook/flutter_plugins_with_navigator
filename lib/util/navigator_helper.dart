import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/util/route_helper.dart';

///描述:当前路由帮助类 navigator 2.0专用
///功能介绍:封装了路由操作信息
///创建者:翁益亨
///创建日期:2022/5/30 19:10

///页面跳转统一封装方法，将当前的路由的跳转能力<委托>到文件中的navigator进行跳转
///传递跳转路由类型 + 传递的参数
typedef OnJumpTo = Function(RoutePageType routePageType,{Map args});

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

  //当前委托路由信息
  RouteListener? _routeListener;

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