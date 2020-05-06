// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basement_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BasementReportAdapter extends TypeAdapter<BasementReport> {
  @override
  final typeId = TABLE_BASEMENT_REPORT;

  @override
  BasementReport read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BasementReport(
      CustomerId: fields[62] as String,
      CompanyId: fields[0] as String,
      OutsideRelativeHumidity: fields[2] as double,
      FirstFloorTemperature: fields[5] as double,
      RelativeOther1: fields[6] as String,
      RelativeOther2: fields[7] as String,
      BasementRelativeHumidity: fields[10] as double,
      BasementTemperature: fields[11] as double,
      GroundWaterRating: fields[14] as int,
      IronBacteria: fields[15] as String,
      WallCracks: fields[17] as String,
      ExistingDrainageSystem: fields[22] as String,
      FoundationType: fields[25] as String,
      Bulkhead: fields[26] as String,
      VisualBasementOther: fields[27] as String,
      NoticedSmellsOrOdors: fields[28] as String,
      NoticedSmellsOrOdorsComment: fields[29] as String,
      NoticedMoldOrMildewComment: fields[31] as String,
      BasementGoDown: fields[32] as String,
      HomeSufferForrespiratoryComment: fields[34] as String,
      ChildrenPlayInBasement: fields[35] as String,
      ChildrenPlayInBasementComment: fields[36] as String,
      NoticedBugsOrRodentsComment: fields[40] as String,
      GetWaterComment: fields[45] as String,
      SeeCondensationPipesDrippingComment: fields[48] as String,
      LivingPlan: fields[51] as String,
      SellPlaning: fields[52] as String,
      PlansForBasementOnce: fields[53] as String,
      HomeTestForPastRadonComment: fields[55] as String,
      LosePowerHowOften: fields[57] as String,
      Notes: fields[59] as String,
    )
      ..CurrentOutsideConditions = fields[1] as String
      ..OutsideTemperature = fields[3] as double
      ..FirstFloorRelativeHumidity = fields[4] as double
      ..Heat = fields[8] as String
      ..Air = fields[9] as String
      ..BasementDehumidifier = fields[12] as String
      ..GroundWater = fields[13] as String
      ..IronBacteriaRating = fields[16] as int
      ..Condensation = fields[60] as String
      ..CondensationRating = fields[61] as int
      ..WallCracksRating = fields[18] as int
      ..FloorCracks = fields[19] as String
      ..FloorCracksRating = fields[20] as int
      ..ExistingSumpPump = fields[21] as String
      ..ExistingRadonSystem = fields[23] as String
      ..DryerVentToCode = fields[24] as String
      ..NoticedMoldOrMildew = fields[30] as String
      ..HomeSufferForRespiratory = fields[33] as String
      ..PetsGoInBasement = fields[37] as String
      ..PetsGoInBasementComment = fields[38] as String
      ..NoticedBugsOrRodents = fields[39] as String
      ..GetWater = fields[41] as String
      ..RemoveWater = fields[46] as String
      ..SeeCondensationPipesDripping = fields[47] as String
      ..RepairsProblems = fields[49] as String
      ..RepairsProblemsComment = fields[50] as String
      ..HomeTestForPastRadon = fields[54] as String
      ..LosePower = fields[56] as String
      ..CustomerBasementOther = fields[58] as String;
  }

  @override
  void write(BinaryWriter writer, BasementReport obj) {
    writer
      ..writeByte(60)
      ..writeByte(0)
      ..write(obj.CompanyId)
      ..writeByte(1)
      ..write(obj.CurrentOutsideConditions)
      ..writeByte(2)
      ..write(obj.OutsideRelativeHumidity)
      ..writeByte(3)
      ..write(obj.OutsideTemperature)
      ..writeByte(4)
      ..write(obj.FirstFloorRelativeHumidity)
      ..writeByte(5)
      ..write(obj.FirstFloorTemperature)
      ..writeByte(6)
      ..write(obj.RelativeOther1)
      ..writeByte(7)
      ..write(obj.RelativeOther2)
      ..writeByte(8)
      ..write(obj.Heat)
      ..writeByte(9)
      ..write(obj.Air)
      ..writeByte(10)
      ..write(obj.BasementRelativeHumidity)
      ..writeByte(11)
      ..write(obj.BasementTemperature)
      ..writeByte(12)
      ..write(obj.BasementDehumidifier)
      ..writeByte(13)
      ..write(obj.GroundWater)
      ..writeByte(14)
      ..write(obj.GroundWaterRating)
      ..writeByte(15)
      ..write(obj.IronBacteria)
      ..writeByte(16)
      ..write(obj.IronBacteriaRating)
      ..writeByte(60)
      ..write(obj.Condensation)
      ..writeByte(61)
      ..write(obj.CondensationRating)
      ..writeByte(17)
      ..write(obj.WallCracks)
      ..writeByte(18)
      ..write(obj.WallCracksRating)
      ..writeByte(19)
      ..write(obj.FloorCracks)
      ..writeByte(20)
      ..write(obj.FloorCracksRating)
      ..writeByte(21)
      ..write(obj.ExistingSumpPump)
      ..writeByte(22)
      ..write(obj.ExistingDrainageSystem)
      ..writeByte(23)
      ..write(obj.ExistingRadonSystem)
      ..writeByte(24)
      ..write(obj.DryerVentToCode)
      ..writeByte(25)
      ..write(obj.FoundationType)
      ..writeByte(26)
      ..write(obj.Bulkhead)
      ..writeByte(27)
      ..write(obj.VisualBasementOther)
      ..writeByte(28)
      ..write(obj.NoticedSmellsOrOdors)
      ..writeByte(29)
      ..write(obj.NoticedSmellsOrOdorsComment)
      ..writeByte(30)
      ..write(obj.NoticedMoldOrMildew)
      ..writeByte(31)
      ..write(obj.NoticedMoldOrMildewComment)
      ..writeByte(32)
      ..write(obj.BasementGoDown)
      ..writeByte(33)
      ..write(obj.HomeSufferForRespiratory)
      ..writeByte(34)
      ..write(obj.HomeSufferForrespiratoryComment)
      ..writeByte(35)
      ..write(obj.ChildrenPlayInBasement)
      ..writeByte(36)
      ..write(obj.ChildrenPlayInBasementComment)
      ..writeByte(37)
      ..write(obj.PetsGoInBasement)
      ..writeByte(38)
      ..write(obj.PetsGoInBasementComment)
      ..writeByte(39)
      ..write(obj.NoticedBugsOrRodents)
      ..writeByte(40)
      ..write(obj.NoticedBugsOrRodentsComment)
      ..writeByte(41)
      ..write(obj.GetWater)
      ..writeByte(45)
      ..write(obj.GetWaterComment)
      ..writeByte(46)
      ..write(obj.RemoveWater)
      ..writeByte(47)
      ..write(obj.SeeCondensationPipesDripping)
      ..writeByte(48)
      ..write(obj.SeeCondensationPipesDrippingComment)
      ..writeByte(49)
      ..write(obj.RepairsProblems)
      ..writeByte(50)
      ..write(obj.RepairsProblemsComment)
      ..writeByte(51)
      ..write(obj.LivingPlan)
      ..writeByte(52)
      ..write(obj.SellPlaning)
      ..writeByte(53)
      ..write(obj.PlansForBasementOnce)
      ..writeByte(54)
      ..write(obj.HomeTestForPastRadon)
      ..writeByte(55)
      ..write(obj.HomeTestForPastRadonComment)
      ..writeByte(56)
      ..write(obj.LosePower)
      ..writeByte(57)
      ..write(obj.LosePowerHowOften)
      ..writeByte(58)
      ..write(obj.CustomerBasementOther)
      ..writeByte(59)
      ..write(obj.Notes)
      ..writeByte(62)
      ..write(obj.CustomerId);
  }
}
