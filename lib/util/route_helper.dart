import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/page/message_page.dart';

import '../page/detail_page.dart';
import '../page/home_page.dart';
import '../page/login_page.dart';

///描述:路由页面基本信息帮助类Navigator 2.0专用
///功能介绍:将当前页面进行统一处理
///创建者:翁益亨
///创建日期:2022/5/31 10:25


//设置当前的启动模式，直接启动/栈内复用模式
enum LaunchMode{
  standard,//标准模式，默认的启动模式，每次都压入一个新的页面到栈顶
  singleTask,//栈内模式，如果存在对应的页面，就直接清除之前的数据（包括自身），然后再重新压入一个新页面到栈顶
  singleInstance,//单例模式，只要当前存在对应页面，就移除当前页面之前的所有页面
  singleMainTop,//栈顶模式，表示当前一定是首页负载内容页面，一个App中只能有一个页面有负载属性，保证当前作为首页不能再返回上一级页面
}

//生命周期展示，当前只用于tab中子容器的回调类型展示，主容器还是需要通过自身类型匹配生效
enum LifeCycle{
  onResume,//隐藏后显示回调
  onPause,//当前界面隐藏显示
  unKnow,//未知生命周期，不需要执行的生命周期传递该类型
}

//声明当前路由跳转的路由页面类型
///@Iteration must be implemented
/*每次新增路由页面必须新增枚举*/
enum RoutePageType {
  login(PageAttribute(),url: "/login"),
  home(PageAttribute(launchMode: LaunchMode.singleMainTop),url: "/home") ,
  detail(PageAttribute(launchMode: LaunchMode.singleTask),url: "/detail") ,
  message(PageAttribute(launchMode: LaunchMode.singleInstance),url: "/message"),

  unknown(PageAttribute(),url: "/unknown")

  ;

  //当前声明的路由信息，web需要，兼容当前网址后缀url显示内容
  final String? url;

  //当前页面的启动模式
  final PageAttribute pageAttribute;

  const RoutePageType(this.pageAttribute,{this.url});
}

//根据当前构建路由信息，获取对应路由的页面类型
///@Iteration must be implemented
/*每次新增路由页面必须新增路由类型*/
RoutePageType getPageType(MaterialPage page){
  //由于页面声明的child为当前实际路由页面信息，所以这里获取页面的child进行类型匹配
  if(page.child is LoginPage){
    return RoutePageType.login;
  }else if(page.child is HomePage){
    return RoutePageType.home;
  }else if(page.child is DetailPage){
    return RoutePageType.detail;
  }else if(page.child is MessagePage){
    return RoutePageType.message;
  }else{
    return RoutePageType.unknown;
  }
}

//根据当前的页面类型获取页面信息
///@Iteration must be implemented
/*每次新增路由页面必须新增路由*/
Widget getPage(RoutePageType routePageType,{Map? arguments}){
  switch(routePageType){
    case RoutePageType.login:
      return LoginPage();
    case RoutePageType.home:
      return HomePage();
    case RoutePageType.detail:
      return DetailPage(arguments:arguments);
    case RoutePageType.message:
      return MessagePage();
    default:
      return const SizedBox();
  }
}

//根据路由字符串获取对应的路由枚举类型，目前提供web端解析使用
RoutePageType getRoutePageType(String url){

  RoutePageType pageType = RoutePageType.unknown;
  RoutePageType.values.forEach((element) {
    if(element.url==url){
      pageType = element;
    }
  });

  return pageType;
}


class PageAttribute{

  //页面自身属性记录，默认启动模式是标准模式
  final LaunchMode launchMode;

  const PageAttribute({this.launchMode = LaunchMode.standard});

}