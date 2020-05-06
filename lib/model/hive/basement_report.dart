
import 'package:hive/hive.dart';

import '../../utils.dart';

part 'basement_report.g.dart';

@HiveType(typeId: TABLE_BASEMENT_REPORT)
class BasementReport {
  @HiveField(0)
  String CompanyId;
  @HiveField(1)
  String CurrentOutsideConditions;
  @HiveField(2)
  double OutsideRelativeHumidity;
  @HiveField(3)
  double OutsideTemperature;
  @HiveField(4)
  double FirstFloorRelativeHumidity;
  @HiveField(5)
  double FirstFloorTemperature;
  @HiveField(6)
  String RelativeOther1;
  @HiveField(7)
  String RelativeOther2;
  @HiveField(8)
  String Heat;
  @HiveField(9)
  String Air;
  @HiveField(10)
  double BasementRelativeHumidity;
  @HiveField(11)
  double BasementTemperature;
  @HiveField(12)
  String BasementDehumidifier;
  @HiveField(13)
  String GroundWater;
  @HiveField(14)
  int GroundWaterRating;
  @HiveField(15)
  String IronBacteria;
  @HiveField(16)
  int IronBacteriaRating;
  @HiveField(60)
  String Condensation;
  @HiveField(61)
  int CondensationRating;
  @HiveField(17)
  String WallCracks;
  @HiveField(18)
  int WallCracksRating;
  @HiveField(19)
  String FloorCracks;
  @HiveField(20)
  int FloorCracksRating;
  @HiveField(21)
  String ExistingSumpPump;
  @HiveField(22)
  String ExistingDrainageSystem;
  @HiveField(23)
  String ExistingRadonSystem;
  @HiveField(24)
  String DryerVentToCode;
  @HiveField(25)
  String FoundationType;
  @HiveField(26)
  String Bulkhead;
  @HiveField(27)
  String VisualBasementOther;
  @HiveField(28)
  String NoticedSmellsOrOdors;
  @HiveField(29)
  String NoticedSmellsOrOdorsComment;
  @HiveField(30)
  String NoticedMoldOrMildew;
  @HiveField(31)
  String NoticedMoldOrMildewComment;
  @HiveField(32)
  String BasementGoDown;
  @HiveField(33)
  String HomeSufferForRespiratory;
  @HiveField(34)
  String HomeSufferForrespiratoryComment;
  @HiveField(35)
  String ChildrenPlayInBasement;
  @HiveField(36)
  String ChildrenPlayInBasementComment;
  @HiveField(37)
  String PetsGoInBasement;
  @HiveField(38)
  String PetsGoInBasementComment;
  @HiveField(39)
  String NoticedBugsOrRodents;
  @HiveField(40)
  String NoticedBugsOrRodentsComment;
  @HiveField(41)
  String GetWater;
  @HiveField(45)
  String GetWaterComment;
  @HiveField(46)
  String RemoveWater;
  @HiveField(47)
  String SeeCondensationPipesDripping;
  @HiveField(48)
  String SeeCondensationPipesDrippingComment;
  @HiveField(49)
  String RepairsProblems;
  @HiveField(50)
  String RepairsProblemsComment;
  @HiveField(51)
  String LivingPlan;
  @HiveField(52)
  String SellPlaning;
  @HiveField(53)
  String PlansForBasementOnce;
  @HiveField(54)
  String HomeTestForPastRadon;
  @HiveField(55)
  String HomeTestForPastRadonComment;
  @HiveField(56)
  String LosePower;
  @HiveField(57)
  String LosePowerHowOften;
  @HiveField(58)
  String CustomerBasementOther;
  @HiveField(59)
  String Notes;
  @HiveField(62)
  String CustomerId;

  BasementReport(
      {
      this.CustomerId,
      this.CompanyId,
      this.OutsideRelativeHumidity,
      this.FirstFloorTemperature,
      this.RelativeOther1,
      this.RelativeOther2,
      this.BasementRelativeHumidity,
      this.BasementTemperature,
      this.GroundWaterRating,
      this.IronBacteria,
      this.WallCracks,
      this.ExistingDrainageSystem,
      this.FoundationType,
      this.Bulkhead,
      this.VisualBasementOther,
      this.NoticedSmellsOrOdors,
      this.NoticedSmellsOrOdorsComment,
      this.NoticedMoldOrMildewComment,
      this.BasementGoDown,
      this.HomeSufferForrespiratoryComment,
      this.ChildrenPlayInBasement,
      this.ChildrenPlayInBasementComment,
      this.NoticedBugsOrRodentsComment,
      this.GetWaterComment,
      this.SeeCondensationPipesDrippingComment,
      this.LivingPlan,
      this.SellPlaning,
      this.PlansForBasementOnce,
      this.HomeTestForPastRadonComment,
      this.LosePowerHowOften,
      this.Notes});
}
