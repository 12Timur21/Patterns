import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memory_box/blocks/audioplayer/audioplayer_bloc.dart';
import 'package:memory_box/blocks/tale_builders/list_builder/list_builder_bloc.dart';
import 'package:memory_box/models/tale_model.dart';
import 'package:memory_box/repositories/database_service.dart';
import 'package:memory_box/repositories/storage_service.dart';
import 'package:memory_box/resources/app_coloros.dart';
import 'package:memory_box/resources/app_icons.dart';
import 'package:memory_box/screens/playlist_screen/select_tales_to_playlist_screen.dart';
import 'package:memory_box/widgets/audioplayer/audio_player.dart';
import 'package:memory_box/widgets/backgoundPattern.dart';
import 'package:memory_box/widgets/tale_list_tiles/tale_list_tile_with_popup_menu.dart';
import 'package:memory_box/widgets/undoButton.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class CreatePlaylistScreen extends StatefulWidget {
  static const routeName = 'CreatePlaylistScreen';

  const CreatePlaylistScreen({Key? key}) : super(key: key);

  @override
  _CreatePlaylistScreenState createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  ListBuilderBloc? _listBuilderBloc;

  final _formController = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();

  final _scrollController = ScrollController();

  bool _isImageValid = true;
  File? _playlistCover;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateImageField() {
    setState(() {
      if (_playlistCover != null) {
        _isImageValid = true;
      } else {
        _isImageValid = false;
      }
    });

    return _isImageValid;
  }

  Future<void> _saveCollection() async {
    _isImageValid = _validateImageField();

    if (_formController.currentState!.validate() && _isImageValid) {
      String playlistID = const Uuid().v4();

      String coverUrl = await StorageService.instance.uploadPlayListCover(
        file: _playlistCover!,
        coverID: playlistID,
      );

      await DatabaseService.instance.createPlaylist(
        playlistID: playlistID,
        title: _titleController.text,
        description: _descriptionController.text,
        talesModels: _listBuilderBloc?.state.allTales,
        coverUrl: coverUrl,
      );

      Navigator.of(context).pop();
    }
  }

  void _undoChanges() {
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    String? path = pickedImage?.path;
    if (path != null) {
      setState(() {
        _isImageValid = true;
        _playlistCover = File(path);
      });
    }
  }

  Future<void> _addTales() async {
    List<TaleModel>? _listTaleModels = await Navigator.of(context).pushNamed(
      SelectTalesToPlaylistScreen.routeName,
      arguments: _listBuilderBloc?.state.allTales,
    ) as List<TaleModel>?;

    _listBuilderBloc?.add(
      InitializeListBuilderWithTaleModels(_listTaleModels),
    );
    // setState(() {});
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ListBuilderBloc(),
        ),
        BlocProvider(
          create: (context) => AudioplayerBloc()
            ..add(
              InitPlayer(),
            ),
        ),
      ],
      child: BackgroundPattern(
        patternColor: AppColors.seaNymph,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            primary: true,
            toolbarHeight: 70,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            leading: UndoButton(
              undoChanges: _undoChanges,
            ),
            title: Container(
              margin: const EdgeInsets.only(top: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Создание',
                  style: TextStyle(
                    fontFamily: 'TTNorms',
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(
                  top: 20,
                  right: 15,
                ),
                child: TextButton(
                  onPressed: _saveCollection,
                  child: const Text(
                    'Готово',
                    style: TextStyle(
                      fontFamily: 'TTNorms',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
            elevation: 0,
          ),
          body: Container(
            margin: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Form(
                key: _formController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Пожалуйста, введите название подборки';
                        }

                        if (text.length > 20) {
                          return 'Слишком длинное название';
                        }

                        return null;
                      },
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Название...',
                        hintStyle: TextStyle(
                          fontFamily: 'TTNorms',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.wildSand.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          border: _isImageValid
                              ? null
                              : Border.all(
                                  width: 2,
                                  color: Colors.red,
                                ),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 4),
                              blurRadius: 20,
                              // spreadRadius: 1,
                              color: Colors.black.withOpacity(0.25),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _playlistCover != null
                                    ? Image.file(
                                        _playlistCover!,
                                        fit: BoxFit.fitWidth,
                                      )
                                    : null,
                              ),
                            ),
                            Center(
                              child: SvgPicture.asset(
                                AppIcons.chosePhoto,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextFormField(
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        hintText: 'Введите описание...',
                        focusColor: Colors.red,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _descriptionController,
                      validator: (text) {
                        if (text != null && text.length > 120) {
                          return 'Слишком длинное название';
                        }

                        return null;
                      },
                      maxLines: 3,
                      minLines: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _listBuilderBloc?.state.allTales.isNotEmpty ?? false
                            ? TextButton(
                                onPressed: _addTales,
                                child: const Text(
                                  'Изменить список',
                                  style: TextStyle(
                                    fontFamily: 'TTNorms',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.transparent,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.black,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(0, -5),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        TextButton(
                          onPressed: () => FocusScope.of(context).unfocus(),
                          child: const Text(
                            'Готово',
                            style: TextStyle(
                              fontFamily: 'TTNorms',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 300,
                      child: BlocConsumer<ListBuilderBloc, ListBuilderState>(
                          listener: (context, state) {
                        if (state is PlayTaleState) {
                          final TaleModel taleModel =
                              state.currentPlayTaleModel!;
                          context.read<AudioplayerBloc>().add(
                                Play(
                                  taleModel: taleModel,
                                  isAutoPlay: true,
                                ),
                              );
                        }

                        if (state is StopTaleState) {
                          context.read<AudioplayerBloc>().add(
                                Pause(),
                              );
                        }
                      }, builder: (context, listBuilderState) {
                        _listBuilderBloc = context.read<ListBuilderBloc>();
                        return Stack(
                          children: [
                            //LIST
                            _listBuilderBloc?.state.allTales.isNotEmpty ?? true
                                ? ListView.builder(
                                    itemCount:
                                        listBuilderState.allTales.length + 1,
                                    itemBuilder: (context, index) {
                                      if (listBuilderState.allTales.length ==
                                          index) {
                                        return const SizedBox(
                                          height: 90,
                                        );
                                      }
                                      TaleModel taleModel =
                                          listBuilderState.allTales[index];
                                      bool isPlayMode = false;

                                      if (listBuilderState
                                                  .currentPlayTaleModel ==
                                              taleModel &&
                                          listBuilderState.isPlay) {
                                        isPlayMode = true;
                                      }

                                      return TaleListTileWithPopupMenu(
                                          key: UniqueKey(),
                                          isPlayMode: isPlayMode,
                                          taleModel: taleModel,
                                          onAddToPlaylist: () {},
                                          onDelete: () => _listBuilderBloc?.add(
                                                DeleteTale(index),
                                              ),
                                          onRename: (String newTitle) =>
                                              _listBuilderBloc?.add(
                                                RenameTale(
                                                  taleModel.ID,
                                                  newTitle,
                                                ),
                                              ),
                                          onShare: () =>
                                              Share.share(taleModel.url),
                                          onUndoRenaming: () =>
                                              _listBuilderBloc?.add(
                                                UndoRenameTale(),
                                              ),
                                          tooglePlayMode: () {
                                            _scrollDown();
                                            _listBuilderBloc?.add(
                                              TooglePlayMode(
                                                taleModel: taleModel,
                                              ),
                                            );
                                          });
                                    },
                                  )
                                : Center(
                                    child: TextButton(
                                      onPressed: _addTales,
                                      child: const Text(
                                        'Добавить аудиофайл',
                                        style: TextStyle(
                                          // height: 2,
                                          fontFamily: 'TTNorms',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Colors.transparent,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.black,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              offset: Offset(0, -5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            //AudioPlayer
                            BlocConsumer<AudioplayerBloc, AudioplayerState>(
                              listener: (context, state) {
                                if (state.isTaleEnd) {
                                  if (listBuilderState.isPlayAllTalesMode) {
                                    _listBuilderBloc?.add(
                                      NextTale(),
                                    );
                                  } else {
                                    _listBuilderBloc?.add(
                                      TooglePlayMode(),
                                    );
                                    context.read<AudioplayerBloc>().add(
                                          AnnulAudioPlayer(),
                                        );
                                  }
                                }
                              },
                              builder: (context, state) {
                                if (state.isTaleInit) {
                                  return Container(
                                    alignment: Alignment.bottomCenter,
                                    margin: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    child: AudioPlayer(
                                      taleModel: state.taleModel,
                                      currentPlayPosition:
                                          state.currentPlayPosition,
                                      isPlay: listBuilderState.isPlay,
                                      isNextButtonAvalible: false,
                                      tooglePlayMode: () =>
                                          _listBuilderBloc?.add(
                                        TooglePlayMode(
                                          taleModel: state.taleModel,
                                        ),
                                      ),
                                      onSliderChangeEnd: (value) => context
                                          .read<AudioplayerBloc>()
                                          .add(
                                            Seek(currentPlayTimeInSec: value),
                                          ),
                                      onSliderChanged: () => {},
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
