import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/weekday.dart';

const weekdays = <WeekDay> {
  WeekDay(key: 'MON', name: 'Lunes', color: AppColors.mondayColor),
  WeekDay(key: 'TUE', name: 'Martes', color: AppColors.tuesdayColor),
  WeekDay(key: 'WED', name: 'Miércoles', color: AppColors.wednesdayColor),
  WeekDay(key: 'THU', name: 'Jueves', color: AppColors.thursdayColor),
  WeekDay(key: 'FRI', name: 'Viernes', color: AppColors.fridayColor),
  WeekDay(key: 'SAT', name: 'Sábado', color: AppColors.saturdayColor),
  WeekDay(key: 'SUN', name: 'Domingo', color: AppColors.sundayColor)
};