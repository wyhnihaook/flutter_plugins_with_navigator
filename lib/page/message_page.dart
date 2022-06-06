import 'package:flutter/material.dart';

import '../util/navigator_helper.dart';
import '../util/route_helper.dart';

///描述:提供Tab监听生命周期
///功能介绍:Tab页面事件切换的监听
///回收从子容器开始回收，最后回收主容器
///创建者:翁益亨
///创建日期:2022/6/2 10:16

//记录当前的tab监听名称
//所有监听器的Tag都在这里声明，只是一个标识，不需要完全匹配对应的数据，保证唯一性即可
const tabContainerTags = ['MessagePage-MainMainTabPage',
  'MessagePage-MineMineTabPage'];

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {

  //当前PageView的控制类,声明初始化的角标
  final PageController _controller = PageController();
  //当前展示页面
  List<Widget> _pages = [];

  //当前点击的index
  int _currentIndex = 0;

  RouteChangeListener? _listener;

  @override
  void initState(){
    super.initState();

    _pages = [
      const MainTabPage(),
      const MineTabPage()
    ];

    //初始化时，添加对应的数据内容，标识当前已经存在监听内容
    //父容器回调监听，子容器回调onResume和onPause通过父容器下发
    NavigatorHelper.getInstance().addListener(_listener = (current, pre)  {
      if(current.page == widget || current.page is MessagePage){
        //onResume，调用子容器响应的数据
        //判断当前_currentIndex数值，进行手动传递回调
        NavigatorHelper.getInstance().notifyTabChange(tabContainerTags[_currentIndex],
        LifeCycle.onResume);
      }else if(pre?.page == widget||pre?.page is MessagePage){
        //onPause，调用子容器响应的回调数据
        NavigatorHelper.getInstance().notifyTabChange(tabContainerTags[_currentIndex],
            LifeCycle.onPause);
      }
    });

    //初始化时进行当前数据的监听处理，按需实现

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('消息Tab页面'),
      ),
      body: PageView(
        controller: _controller,
        children: _pages,
        onPageChanged: (int value){
          //当前选中tab回调
          checkIndex(value);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index){
          //点击tab回调
          checkIndex(index);
          //控制上述PageView切换
          _controller.jumpToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          _bottomItem("首页",(Icons.home)),
          _bottomItem("我的",(Icons.mic)),
        ],
      ),
    );
  }


//当前滑动切换时同步数据

  void checkIndex(int index){
    //相同切换不做响应，避免生命周期多次执行
    if(_currentIndex == index){
      return ;
    }
    print("${_pages[index]}  $index");
    //切换当前的Tab回调处理当前显示与否,控制切换当前内容
    NavigatorHelper.getInstance().switchTabChange(tabContainerTags[index],
    tabContainerTags[_currentIndex]);

    setState((){
      _currentIndex = index;
    });
  }

  @override
  void dispose(){
    NavigatorHelper.getInstance().removeListener(_listener!);
    super.dispose();

  }
}


_bottomItem(String title, IconData icon) {
  return BottomNavigationBarItem(
      icon: Icon(icon),
      label: title);
}


///当前TabView都在该类中声明，便于观察。实际上开发需要单独声明
class MainTabPage extends StatefulWidget {
  const MainTabPage({Key? key}) : super(key: key);

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> with AutomaticKeepAliveClientMixin{

  int _count = 0;

  @override
  void initState(){
    super.initState();

    // ("Message-$widget") 输出的是：父容器名称-子容器名称
    //添加Tab监听器
    NavigatorHelper.getInstance().addSubContainerListener(tabContainerTags[0], (lifeCycle){
      switch(lifeCycle){
        case LifeCycle.onResume:
          print('${tabContainerTags[0]} onresume');
          break;
        case LifeCycle.onPause:
          print('${tabContainerTags[0]} onpause');
          break;
      }
    });
  }


  @override
  void dispose(){
    print("mainTabmainmain  dispose");
    //移除子容器的监听
    NavigatorHelper.getInstance().removeSubContainerListener(tabContainerTags[0]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count'),
        ElevatedButton(onPressed: (){
          setState((){
            _count++;
          });
          NavigatorHelper.getInstance().onJumpTo(RoutePageType.detail,args: {"id":2});
        }, child:const Text('我是message的首页'))
      ],
    );
  }

  //需要保存缓存状态必须设置AutomaticKeepAliveClientMixin
  //当然，这里可以进行封装，将tab需要的都被容器包裹一层，为该容器添加额外功能，维护当前的状态
  @override
  bool get wantKeepAlive => true;
}


class MineTabPage extends StatefulWidget {
  const MineTabPage({Key? key}) : super(key: key);

  @override
  State<MineTabPage> createState() => _MineTabPageState();
}

class _MineTabPageState extends State<MineTabPage>  with AutomaticKeepAliveClientMixin{

  @override
  void initState(){
    super.initState();
    NavigatorHelper.getInstance().addSubContainerListener(tabContainerTags[1], (lifeCycle){
      switch(lifeCycle){
        case LifeCycle.onResume:
          print('${tabContainerTags[1]} onresume');
          break;
        case LifeCycle.onPause:
          print('${tabContainerTags[1]} onpause');
          break;
      }
    });
  }

  @override
  void dispose(){
    print("minemineTabmine  dispose");

    NavigatorHelper.getInstance().removeSubContainerListener(tabContainerTags[1]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: (){
          NavigatorHelper.getInstance().onJumpTo(RoutePageType.detail,args: {"id":888});
        }, child:const Text('我是Message的我的页面'))
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}


