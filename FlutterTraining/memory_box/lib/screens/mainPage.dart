import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/bottomSheetNavigation/bottomSheet_bloc.dart';
import 'package:memory_box/blocks/bottomSheetNavigation/bottomSheet_state.dart';
import 'package:memory_box/blocks/mainPageNavigation/navigation_bloc.dart';
import 'package:memory_box/blocks/mainPageNavigation/navigation_state.dart';
import 'package:memory_box/blocks/recorderButton/recorderButton._event.dart';
import 'package:memory_box/blocks/recorderButton/recorderButton_bloc.dart';
import 'package:memory_box/blocks/recorderButton/recorderButton_state.dart';
import 'package:memory_box/screens/Recording/listeningPage.dart';
import 'package:memory_box/screens/audioListPage.dart';
import 'package:memory_box/screens/collections/collectionsListPage.dart';
import 'package:memory_box/screens/homePage.dart';
import 'package:memory_box/screens/profilePage.dart';
import 'package:memory_box/screens/recording/recordPreview.dart';
import 'package:memory_box/screens/selectionsPage.dart';
import 'package:memory_box/screens/subscriptionPage.dart';
import 'package:memory_box/widgets/bottomNavigationBar.dart';
import 'package:memory_box/widgets/navigationMenu.dart';

import 'Recording/recordingPage.dart';
import 'collections/createCollectionPage.dart';
import 'collections/selectSoundCollection.dart';

class MainPage extends StatefulWidget {
  static const routeName = 'MainPage';

  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextStyle bottomNavigationBarTextStyle = const TextStyle(
    fontFamily: 'TTNorms',
    fontWeight: FontWeight.w400,
    fontSize: 11,
  );

  bool isOpenBottomSheet = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBottomSheet() {
    isOpenBottomSheet = true;
    _scaffoldKey.currentState
        ?.showBottomSheet(
          (BuildContext context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<BottomSheetBloc>(
                  create: (context) => BottomSheetBloc(
                    ListeningPageState(),
                  ),
                ),
                BlocProvider(
                  create: (context) => AudioplayerBloc(),
                ),
              ],
              // child: GestureDetector(
              // onVerticalDragDown: (_) {},
              child: BlocBuilder<BottomSheetBloc, BottomSheetState>(
                builder: (BuildContext context, BottomSheetState state) {
                  if (state is RecorderPageState) {
                    return const RecordingPage();
                  }
                  if (state is ListeningPageState) {
                    return const ListeningPage();
                  }
                  if (state is PreviewPageState) {
                    return RecordPreview(
                      soundTitle: state.soundTitle,
                    );
                  }
                  return Container();
                },
              ),
              // ),
            );
          },
          // transitionAnimationController: transition,
          backgroundColor: Colors.transparent,
        )
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              changeRecoringButtonToDefault();
              isOpenBottomSheet = false;
            });
          }
        });
  }

  void changeRecoringButtonToDefault() {
    final recorderButtomBloc = BlocProvider.of<RecorderButtomBloc>(context);
    recorderButtomBloc.add(
      ChangeIcon(
        RecorderButtonStates.WithIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: const NavigationBar(),
      body: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (BuildContext context, NavigationState state) {
          print(state.selectedItem);
          if (state.selectedItem == NavigationPages.HomePage) {
            return const HomePage();
          }
          if (state.selectedItem == NavigationPages.CollectionsListPage) {
            return const SelectSoundCollection();
          }
          if (state.selectedItem == NavigationPages.AudioListPage) {
            return const AudioListPage();
          }
          if (state.selectedItem == NavigationPages.ProfilePage) {
            return ProfilePage();
          }
          if (state.selectedItem == NavigationPages.SubscriptionPage) {
            return SubscriptionPage();
          }
          return Container();
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavBar(
            openButtomSheet: _showBottomSheet,
          ),
        ),
      ),
    );
  }
}
