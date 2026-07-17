import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuItem {
  final String title;
  final String subTitle;
  final String link;
  final Widget icon;

  const MenuItem({
    required this.title,
    required this.subTitle,
    required this.link,
    required this.icon
  });
}

final appMenuItems = <MenuItem>[
  MenuItem(
    title: 'Mis Entrenamientos',
    subTitle: 'Crea tus propias rutinas de ejercicios',
    link: '/routines',
    icon: Icon(Icons.assignment_outlined, size: 22),
  ),
  MenuItem(
    title: 'Estadísticas',
    subTitle: 'Revisa tus estadísticas',
    link: '/statistics',
    icon: Icon(Icons.bar_chart, size: 22),
  ),
  MenuItem(
    title: 'Ejercicios',
    subTitle: 'Revisa tus estadísticas',
    link: '/exercises',
    icon: SvgPicture.asset(
      'assets/icons/dumbbells.svg',
      width: 22,
      height: 22
    ),
  )
];