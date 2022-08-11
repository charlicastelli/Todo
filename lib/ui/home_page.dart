import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/services/notification_services.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/add_task_bar.dart';
import 'package:todo/ui/theme.dart';
import 'package:todo/ui/widgets/button.dart';

import 'widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  String _timeNow = DateFormat("Hm").format(DateTime.now()).toString();
  final _taskController = Get.put(TaskController());
  var notifyHelper = NotifyHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification;
    notifyHelper.requestIOSPermissions();
    _taskController
        .getTasks(); // se não carregar as tarefas salvas posso apagar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(children: [
        _addTaskBar(),
        _addDateBar(),
        SizedBox(
          height: 10,
        ),
        _showTasks(),
      ]),
    );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];
              //print(task.toJson());
              // if (task.repeat == 'Diariamente') {
              //   DateTime date =
              //       DateFormat.Hm().parse(task.startTime.toString());
              //   var myTime = DateFormat("Hm").format(date);

              //   print(myTime);
              //   notifyHelper.scheduledNotification(
              //       int.parse(myTime.toString().split(":")[0]),
              //       int.parse(myTime.toString().split(":")[1]),
              //       task);
              //   return AnimationConfiguration.staggeredList(
              //       position: index,
              //       child: SlideAnimation(
              //         child: FadeInAnimation(
              //             child: Row(children: [
              //           GestureDetector(
              //             onTap: (() {
              //               _showBottomSheet(context, task);
              //             }),
              //             child: TaskTile(task),
              //           )
              //         ])),
              //       ));
              // }
              if (task.date == DateFormat('dd/MM/yyyy').format(_selectedDate)) {
                DateTime date =
                    DateFormat.Hm().parse(task.startTime.toString());
                var myTime = DateFormat("Hm").format(date);

                print(date);
                print(task.endTime);
                print(_timeNow);

                notifyHelper.scheduledNotification(
                    int.parse(myTime.toString().split(":")[0]),
                    int.parse(myTime.toString().split(":")[1]),
                    task);

                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(children: [
                        GestureDetector(
                          onTap: (() {
                            _showBottomSheet(context, task);
                          }),
                          child: TaskTile(task),
                        )
                      ])),
                    ));
              } else {
                return Container();
              }
            });
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.only(top: 4),
      height: task.isCompleted == 1
          ? MediaQuery.of(context).size.height * 0.24
          : MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : Colors.white,
      child: Column(children: [
        //entalhe topo do container
        Container(
          height: 6,
          width: 120,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
        ),
        Spacer(),
        task.isCompleted == 1
            ? Container()
            : _bottomSheetButton(
                label: "Tarefa completa",
                onTap: () {
                  _taskController.markTaskCompleted(task.id!);
                  Get.back();
                },
                clr: primaryClr,
                context: context),

        SizedBox(
          height: 5,
        ),
        _bottomSheetButton(
            label: "Apagar tarefa",
            onTap: () {
              _taskController.delete(task);
              //_taskController.getTasks(); //atualiza a tela
              Get.back();
            },
            clr: Colors.redAccent,
            context: context),
        SizedBox(
          height: 20,
        ),
        _bottomSheetButton(
            label: "Fechar",
            onTap: () {
              Get.back();
            },
            clr: Colors.redAccent,
            isClose: true,
            context: context),
        SizedBox(
          height: 10,
        ),
      ]),
    ));
  }

  _bottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color clr,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose == true
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose == true ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text(
                  "Hoje",
                  style: headingStyle,
                )
              ],
            ),
          ),
          MyButton(
              label: "Adicionar tarefa",
              onTap: () async {
                await Get.to(() => const AddTaskPage());
                _taskController.getTasks();
              })
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
          onTap: (() {
            ThemeService().switchThemeMode();
            // notificação de alteração do tema
            notifyHelper.displayNotification(
                title: 'Tema alterado',
                body: Get.isDarkMode
                    ? 'Tema claro ativado'
                    : 'Tema escuro ativado');
            //notifyHelper.scheduledNotification();
          }),
          child: Icon(
              Get.isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.nights_stay_rounded,
              size: 25,
              color: Get.isDarkMode ? Colors.white : Colors.black)),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage("images/icon.png"),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
