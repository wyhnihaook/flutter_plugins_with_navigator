import 'package:shared_preferences/shared_preferences.dart';

///描述:缓存类<使用 shared_preferences 三方库>
///功能介绍:本地持久化存储数据类，当前所有存储和获取都使用异步方式，保证获取成功
///需要放在初始化页面
///
///创建者:翁益亨
///创建日期:2022/5/31 14:03

class CacheHelper {
  //持久化存储对象实例获取
  SharedPreferences? preferences;

  //设计单例使用方式，这里需要往前提，预初始化
  CacheHelper._();

  //自定义预加载初始化当前持久化存储对象
  CacheHelper.pre(SharedPreferences pref){
    preferences = pref;
  }

  static CacheHelper? _instance;
  static CacheHelper getInstance(){
    return _instance??CacheHelper._();
  }

  static Future<CacheHelper> initCache() async{
    if(_instance == null){
      print("cache开始加载当前缓存");

      var preferences = await SharedPreferences.getInstance();
     _instance = CacheHelper.pre(preferences);

      print("cache加载当前缓存完毕");

    }
    return _instance!;
  }

  ///当前存储功能实现

  //字符串存储
  setString(String key ,String value){
    preferences?.setString(key, value);
  }

  //double存储
  setDouble(String key ,double value){
    preferences?.setDouble(key, value);
  }

  //int存储
  setInt(String key ,int value){
    preferences?.setInt(key, value);
  }

  //bool存储
  setBool(String key ,bool value){
    preferences?.setBool(key, value);
  }

  //存储列表信息
  setStringList(String key, List<String> value) {
    preferences?.setStringList(key, value);
  }

  //获取数据
  Object? get<T>(String key){
    return preferences?.get(key);
  }
}
