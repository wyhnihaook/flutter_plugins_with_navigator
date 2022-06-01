import 'package:flutter_plugins_with_componentization/util/cache_helper.dart';

///描述:预初始化类
///功能介绍:统一管理第三方sdk或者需要异步初始化的类信息
///创建者:翁益亨
///创建日期:2022/5/31 14:09
class PreInit{
  //单例初始化，初始化一次即可，默认都会成功
  PreInit._();
  static PreInit? _instance;

  //首页通过FutureBuilder进行处理，可以优先处理一个异步数据，处理完毕之后再进行页面渲染
  //保证当前数据使用正常
  //根据属性设定需要接收一个Future<T>对象，所以再一下信息进行构建

  static Future<PreInit> preLoad() async{
    if(_instance == null){
      //初始化sdk入口
      await CacheHelper.initCache();
      //需要初始化的sdk...

    }
    return _instance??PreInit._();
  }

}