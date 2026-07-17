import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';
import 'package:rg_gym/models/routine.dart';

class RoutineItem extends StatelessWidget {
  final Routine routine;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const RoutineItem({
    super.key,
    required this.routine,
    this.onEdit,
    this.onDuplicate,
    this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/routine', arguments: routine.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Positioned(
              left: 20,
              top: 28,
              child: Text(
                routine.name,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            Positioned(
              right: 55,
              top: -12,
              child: Transform.rotate(
                angle: -0.8,
                child: Image.asset(
                  "assets/images/dumbbell.png",
                  width: 70,
                  height: 70,
                )
              )
            ),

            Positioned(
              right: 12,
              top: 18,
              child: PopupMenuButton<String>(
                color: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12)
                ),
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onSelected: (value) {
                  switch(value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'duplicate':
                      onDuplicate?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 10),
                        Text('Editar')
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 10),
                        Text('Duplicar')
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 10),
                        Text('Eliminar')
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      )
    );
  }
}