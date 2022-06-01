import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/util/navigator_helper.dart';
import 'package:flutter_plugins_with_componentization/util/route_helper.dart';

///描述:首页信息
///功能介绍:
///创建者:翁益亨
///创建日期:2022/5/30 19:13
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页'),),
      body: Column(
        children: [
          Text('首页页面'),
          ElevatedButton(onPressed: (){
            NavigatorHelper.getInstance().onJumpTo(RoutePageType.detail,args: {"id":2});
          }, child: Text('跳转到详情'))
          
        ],
      ),
    );
  }
}
