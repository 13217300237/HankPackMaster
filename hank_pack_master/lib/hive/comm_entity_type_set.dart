
/// 盒子名称
const String envConfigBoxName = "envConfigBox";

/// 给每个持久化的类都创建唯一的编号，以便在数据库升级是做映射
const int envConfigClassType = 0x12138;
/// 这些是字段
const int envConfigEnvNameType = 0x01;
const int envConfigEnvValueType = 0x02;
