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

  RouteChangeListener? _listener;

  @override
  void initState(){
    super.initState();
    //新增监听器，上下基本一起出现，有新增，就有移除
    NavigatorHelper.getInstance().addListener(_listener = (current, pre) {
      if(widget == current.page || current.page is HomePage){
        print("HomePage : onResume");
      }else if(widget == pre?.page || pre?.page is HomePage){
        print("HomePage : onPause");
      }
    });
  }


  @override
  void dispose(){
    //生命周期回收时解除监听器
    NavigatorHelper.getInstance().removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页'),),
      body: Column(
        children: [
          Text('首页页面'),
          ElevatedButton(onPressed: (){
            NavigatorHelper.getInstance().onJumpTo(RoutePageType.message);
          }, child: Text('跳转到详情'))
          
        ],
      ),
    );
  }
}
