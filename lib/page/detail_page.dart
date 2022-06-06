import 'package:flutter/material.dart';
import 'package:flutter_plugins_with_componentization/util/navigator_helper.dart';
import 'package:flutter_plugins_with_componentization/util/route_helper.dart';

///描述:详情页面
///功能介绍:
///创建者:翁益亨
///创建日期:2022/5/30 19:14
class DetailPage extends StatefulWidget {
  final Map? arguments;
  const DetailPage({Key? key,this.arguments}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    print("当前携带参数${widget.arguments}");
    return Scaffold(
      appBar: AppBar(title: Text('详情'),),
      body: Column(
        children: [
          //用来区分detail页面多次创建的内容
          Text('$_count'),
          ElevatedButton(onPressed: (){
            setState((){
              _count++;
            });
          }, child: Text("数据自增+1")),
          ElevatedButton(onPressed: (){
            NavigatorHelper.getInstance().onJumpTo(RoutePageType.home);
          }, child: Text('跳转到首页')),
          ElevatedButton(onPressed: (){
            NavigatorHelper.getInstance().onJumpTo(RoutePageType.message);
          }, child: Text('跳转到消息页面')),
          ElevatedButton(onPressed: (){
            //可以结合启动模式测试当前的detail页面,设置为Standard模式，将会无限制一直新建
            NavigatorHelper.getInstance().onJumpTo(RoutePageType.detail,args:  {"id":3});
          }, child: Text('继续跳转自身detial')),
        ],
      ),
    );
  }
}
