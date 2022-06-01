import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/util/navigator_helper.dart';
import 'package:flutter_plugins_with_componentization/util/route_helper.dart';

import '../util/cache_helper.dart';


///描述:登录页
///功能介绍:TODO
///创建者:翁益亨
///创建日期:2022/5/31 13:40
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登陆"),
      ),
      body: Column(
        children: [
          Text("登录页面"),
          ElevatedButton(onPressed: (){
            CacheHelper.getInstance().setString("token","模拟存储token");

            NavigatorHelper.getInstance().onJumpTo(RoutePageType.home);
          }, child: Text("登录"))
        ],
      ),
    );
  }
}
