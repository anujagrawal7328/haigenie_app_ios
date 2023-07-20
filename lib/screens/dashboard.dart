import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:haigenie/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/score.dart';
import '../model/user.dart';
import '../services/authRepository.dart';
import 'dart:math' as math;

import '../services/model_inference_service.dart';
import '../services/service_locator.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  final List<Score>? score;
  const DashboardScreen({super.key, required this.user, required this.score});
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final FlutterLocalization _localization = FlutterLocalization.instance;
  final AuthRepository authRepository = AuthRepository();
  late AnimationController _animationController;
  bool _isButtonVisible = true;
  List<int> showingTooltipOnSpots = [1, 3, 5];
  bool downloadAvailable = false;
  late User user;
  double? score;
  List<FlSpot> allSpots = [];

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontFamily: 'Digital',
      fontSize: 30 * chartWidth / 2000,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![0].date}';
        } else {
          return Container();
        }
        break;
      case 1:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![1].date}';
        } else {
          return Container();
        }
        break;
      case 2:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![2].date}';
        } else {
          return Container();
        }
        break;
      case 3:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![3].date}';
        } else {
          return Container();
        }
        break;
      case 4:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![4].date}';
        } else {
          return Container();
        }
        break;
      case 5:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![5].date}';
        } else {
          return Container();
        }
        break;
      case 6:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![6].date}';
        } else {
          return Container();
        }
        break;
      case 7:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![7].date}';
        } else {
          return Container();
        }
        break;
      case 8:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![8].date}';
        } else {
          return Container();
        }
        break;
      case 9:
        if (value.toInt() < widget.score!.length) {
          text = '${widget.score![9].date}';
        } else {
          return Container();
        }
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      angle: -math.pi / 4,
      space: 15,
      axisSide: meta.axisSide,
      child: Transform(
          transform: Matrix4.skewY(
              -0.1), // Adjust the skew angle as per your preference
          child: Text(
              '${text.substring(0, 18)}\n${text.substring(18, text.length)}'
                  /*'\n${text.substring(24, text.length)}'*/
              ,
              style: style)),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isButtonVisible = !_isButtonVisible;
          });
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _isButtonVisible = !_isButtonVisible;
          });
          _animationController.forward();
        }
      });

    _animationController.forward();
    if (widget.score!.isNotEmpty) {
      for (int y = 0; y < widget.score!.length; y++) {
        score = widget.score![y].totalScore;
        allSpots.add(FlSpot(double.parse(y.toString()), score!));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('\ ${value}', style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lineBarsData = [
      LineChartBarData(
        isStepLineChart: false,
        spots: allSpots,
        isCurved: false,
        barWidth: 4,
        color: Colors.blueAccent,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0),
            ],
            stops: const [0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 6,
              color: Colors.white,
              strokeWidth: 3,
              strokeColor: Colors.blueAccent,
            );
          },
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];
    return OrientationBuilder(builder: (context, orientation) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child:AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, size: 35.0),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        // title: Image.asset(
        //   'assets/Images/app_icon.png', // Replace with your logo image path
        //   width: 70,
        //   height: 70,
        // ),
        // centerTitle: true,
        actions: [
          Image.asset(
            'assets/Images/app_icon.png', // Replace with your logo image path
            width: 80,
            height: 80,
          ),
          downloadAvailable
              ? IconButton(
                  icon: const Icon(Icons.download, size: 30.0),
                  onPressed: () {
                    // Perform download action
                  },
                )
              : const Text(''),
        ],
      )),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${widget.user.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.user.email}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Profile',
                  style: TextStyle(
                    color: Colors.black,
                  )),
              onTap: () {
                Navigator.of(context).pushNamed('/settings',arguments: [widget.user]);
              },
            ),
         /*   ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Account Deletion Request',
                  style: TextStyle(
                    color: Colors.black,
                  )),
              onTap: () {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'support@datakalp.com',
                  query: encodeQueryParameters(<String, String>{
                    'subject': 'Request for permanent Account Deletion Request',
                  }),
                );

                launchUrl(emailLaunchUri);
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout',
                  style: TextStyle(
                    color: Colors.black,
                  )),
              onTap: () async {
                bool logout = await authRepository.logout();
                if (logout == true) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/auth', // Replace with the route name for your login screen
                    ModalRoute.withName('/auth'), // Remove all existing routes from the stack
                  );
                }
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15.0, MediaQuery.of(context).size.height-420, 0.0,0.0),
             child: Center(
                  child: RichText(text: const TextSpan(children: [
                    TextSpan(
                    text: 'Contact',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  ]
                  ),
                textAlign: TextAlign.center,
                  )),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 0.0,0.0),
              child: Center(
                  child: GestureDetector(
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'support@datakalp.com'
                        );
                        launchUrl(emailLaunchUri);
                      },
                      child:RichText(text: const TextSpan(children: [
                    TextSpan(
                        text: 'support@datakalp.com',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        )),
                  ]
                  ),
                    textAlign: TextAlign.center,
                  ))),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Image.asset(
            'assets/Images/Genie.jpeg', // Replace with your own image path
            width: 180,
            height: 180,
          ),
          Text(
            l10n.landingPageHeading,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
         /* widget.user.userType == "certification"
              ? ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/guide');
                  },
                  child: Text(l10n.guideVideo),
                )
              : Container(),*/
          const SizedBox(height: 16),
     /*     widget.user.userType == "certification"
              ? Text(
                  '${widget.user.availableAttempts} ${l10n.attemptsRemaining}',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                )
              : Container(),*/
         /* const SizedBox(height: 20),*/
          /*  AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isButtonVisible
                        ? const Color(0xFF00a2d8)
                        : Colors.transparent,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.videocam), // Use any desired icon
                    iconSize: 40,
                    color: Colors.white,
                    onPressed: () {
                      locator<ModelInferenceService>().setModelConfig();
                      Navigator.of(context)
                          .pushNamed('/recorder', arguments: [widget.user,widget.score]);
                    },
                  ),
                );
              }),*/
          widget.user.userType == "certification"
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  locator<ModelInferenceService>().setModelConfig();
                  Navigator.of(context).pushNamed('/recorder',
                      arguments: [widget.user, widget.score, true]);
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    elevation:
                    10.0, // Adjust the value to change the button shape
                    shadowColor: Colors.black.withOpacity(
                        0.4), // Adjust the shadow color and opacity
                    splashFactory: InkRipple.splashFactory,
                    backgroundColor: Colors.blue
                ),
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width/2)-50,
                  height: 80.0,
                  child: Center(
                    child:RichText(
                      textAlign: TextAlign.center,
                      text:  TextSpan(
                        children: [
                          TextSpan(
                            text: '${l10n.practice_mode}\n',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: '(${l10n.only} ',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: '${widget.user.availableAttempts}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: ' ${l10n.attempts})',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          /*   TextSpan(
                              text: l10n.guide_message_part_3,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            ),*/
                        ],
                      ),
                    ),
                  ),
                )),
              ElevatedButton(
                  onPressed: () {
                    locator<ModelInferenceService>().setModelConfig();
                    Navigator.of(context).pushNamed('/recorder',
                        arguments: [widget.user, widget.score, false]);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20.0),
                    elevation:
                        4.0, // Adjust the value to change the button shape
                    shadowColor: Colors.black.withOpacity(
                        0.4), // Adjust the shadow color and opacity
                    splashFactory: InkRipple.splashFactory,
                    backgroundColor: Colors.blue
                  ),
                  child:SizedBox(
                    width: MediaQuery.of(context).size.width/2-50,
                    height: 60,
                    child: Center(
                      child:RichText(
                        textAlign: TextAlign.center,
                        text:  TextSpan(
                          children: [
                            TextSpan(
                              text: '${l10n.start_assesment}\n',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: '(${l10n.only} ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.user.certificationAttempts}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: ' ${l10n.attempts})',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          locator<ModelInferenceService>().setModelConfig();
                          Navigator.of(context).pushNamed('/recorder',
                              arguments: [widget.user, widget.score, true]);
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            elevation:
                            10.0, // Adjust the value to change the button shape
                            shadowColor: Colors.black.withOpacity(
                                0.4), // Adjust the shadow color and opacity
                            splashFactory: InkRipple.splashFactory,
                            backgroundColor: Colors.blue
                        ),
                        child: SizedBox(
                          width: (MediaQuery.of(context).size.width/2)-50,
                          height: 50.0,
                          child: Center(
                            child: Text(
                              l10n.practice_guide,
                              style: const TextStyle(fontSize: 15.0,color:Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                   ElevatedButton(
                        onPressed: () {
                          locator<ModelInferenceService>().setModelConfig();
                          Navigator.of(context).pushNamed('/recorder',
                              arguments: [widget.user, widget.score, false]);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10.0),
                          elevation:
                              10.0, // Adjust the value to change the button shape
                          shadowColor: Colors.black.withOpacity(
                              0.4), // Adjust the shadow color and opacity
                          splashFactory: InkRipple.splashFactory,
                          backgroundColor: Colors.blue
                        ),
                        child:SizedBox(
                          width: (MediaQuery.of(context).size.width/2)-50,
                          height: 50.0,
                          child: Center(
                            child: Text(
                              l10n.practice_without_guide,
                              style: const TextStyle(fontSize: 15.0,color:Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.9,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return LineChart(
                  LineChartData(
                    rangeAnnotations: RangeAnnotations(
                      horizontalRangeAnnotations: [
                        HorizontalRangeAnnotation(
                          y1: 0,
                          y2: 2,
                          color: const Color(0xFFfbbfb7).withOpacity(0.5),
                        ),
                        HorizontalRangeAnnotation(
                          y1: 2,
                          y2: 4,
                          color: const Color(0xFFfef6e3).withOpacity(0.5),
                        ),
                        HorizontalRangeAnnotation(
                          y1: 4,
                          y2: 6,
                          color: const Color(0xFFd7eff3).withOpacity(0.5),
                        ),
                      ],
                    ),
                    extraLinesData: ExtraLinesData(
                      extraLinesOnTop: false,
                      horizontalLines: [
                        HorizontalLine(
                          y: 4,
                          color: const Color(0xFF3a6d70),
                          strokeWidth: 0,
                          dashArray: [5,10],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (line) =>  l10n.comments_excellent,
                          ),
                        ),
                        HorizontalLine(
                          y: 2,
                          color: const Color(0xFFf6d797),
                          strokeWidth: 0,
                          dashArray: [5, 10],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (line) =>  l10n.comments_well_done,
                          ),
                        ),
                        HorizontalLine(
                          y: 0,
                          color: const Color(0xFF98463b),
                          strokeWidth: 0,
                          dashArray: [5, 10],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (line) => l10n.comments_do_better,
                          ),
                        ),
                      ],
                    ),
                    lineBarsData: lineBarsData,
                    minY: 0,
                    maxY: 6,
                    maxX: 10,
                    lineTouchData: LineTouchData(
                      getTouchedSpotIndicator:
                          (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          final spot = barData.spots[spotIndex];

                          return TouchedSpotIndicatorData(
                            const FlLine(
                              color: Colors.transparent,
                              strokeWidth: 4,
                            ),
                            FlDotData(
                                getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 8,
                                color: Colors.white,
                                strokeWidth: 5,
                                strokeColor: Colors.yellow,
                              );
                            }),
                          );
                        }).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.white,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final flSpot = barSpot;

                            return LineTooltipItem(
                              '${widget.score![flSpot.x.toInt()].date} \n',
                              const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                const TextSpan(
                                  text: ' Score: ',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(
                                  text: flSpot.y.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                              /*textAlign: textAlign,*/
                            );
                          }).toList();
                        },
                      ),

                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        axisNameSize: 20,
                        axisNameWidget: Text(
                          l10n.haigenieScore,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: leftTitleWidgets,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        axisNameSize: 20,
                        axisNameWidget: Text(
                          '',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return bottomTitleWidgets(
                              value,
                              meta,
                              constraints.maxWidth,
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      topTitles: AxisTitles(
                        axisNameWidget: Text(
                          l10n.yourPastScore,
                          textAlign: TextAlign.left,
                        ),
                        axisNameSize: 24,
                        sideTitles: const SideTitles(
                          showTitles: true,
                          reservedSize: 0,
                        ),
                      ),
                    ),
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      drawHorizontalLine: false,
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      )),
    );
    });
  }
}

Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (colors.length == 1) {
    return colors[0];
  }

  if (stops.length != colors.length) {
    stops = [];

    /// provided gradientColorStops is invalid and we calculate it here
    colors.asMap().forEach((index, color) {
      final percent = 1.0 / (colors.length - 1);
      stops.add(percent * index);
    });
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];
    final leftColor = colors[s];
    final rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}
