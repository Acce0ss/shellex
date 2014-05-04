# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-shellex

CONFIG += sailfishapp

SOURCES += src/harbour-shellex.cpp \
    src/shellexecutor.cpp \
    src/shellcommand.cpp \
    src/commandoutputmodel.cpp \
    src/commandsmodel.cpp \
    src/settings.cpp

OTHER_FILES += qml/harbour-shellex.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-shellex.spec \
    rpm/harbour-shellex.yaml \
    harbour-shellex.desktop \
    qml/pages/MainPage.qml \
    qml/CommandsStore.qml \
    qml/pages/CommandDelegate.qml \
    TODO.txt \
    qml/pages/EditCommandPage.qml \
    qml/pages/SortPage.qml \
    qml/pages/ProcessOutputPage.qml \
    qml/images/running.png \
    qml/pages/CreateScriptPage.qml \
    qml/pages/EditScriptPage.qml \
    qml/Routine.qml \
    qml/pages/InfoPage.qml \
    qml/pages/CommandInfoView.qml \
    qml/pages/NumberOfLinesField.qml \
    qml/GlobalSettings.qml

HEADERS += \
    src/shellexecutor.h \
    src/shellcommand.h \
    src/commandoutputmodel.h \
    src/commandsmodel.h \
    src/settings.h

