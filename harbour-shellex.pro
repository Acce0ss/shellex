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
    src/settings.cpp \
    src/parameterpluginlistmodel.cpp \
    src/commandnamevalidator.cpp

OTHER_FILES += qml/harbour-shellex.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-shellex.spec \
    rpm/harbour-shellex.yaml \
    harbour-shellex.desktop \
    qml/pages/MainPage.qml \
    qml/CommandsStore.qml \
    TODO.txt \
    qml/pages/EditCommandPage.qml \
    qml/pages/SortPage.qml \
    qml/pages/ProcessOutputPage.qml \
    qml/images/running.png \
    qml/Routine.qml \
    qml/GlobalSettings.qml \
    qml/pages/GlobalSettingsPage.qml \
    qml/pages/CreateCommandPage.qml \
    qml/parameterComponents/StringParameter.qml \
    qml/parameterComponents/SliderParameter.qml \
    qml/parameterComponents/SliderParameterSetup.qml \
    qml/parameterComponents/StringParameterSetup.qml \
    qml/components/ParameterSetup.qml \
    qml/pages/ParameterAddPage.qml \
    qml/pages/StartParameterDialog.qml \
    qml/components/ParameterInputs.qml \
    qml/components/CommandDelegate.qml \
    qml/components/CommandInfoView.qml \
    qml/components/NumberOfLinesField.qml \
    qml/parameterComponents/ComboBoxParameter.qml \
    qml/parameterComponents/ComboBoxParameterSetup.qml

HEADERS += \
    src/shellexecutor.h \
    src/shellcommand.h \
    src/commandoutputmodel.h \
    src/commandsmodel.h \
    src/settings.h \
    src/parameterpluginlistmodel.h \
    src/commandnamevalidator.h

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
CODECFORTR = UTF-8
TRANSLATIONS += translations/harbour-shellex-fi.ts translations/harbour-shellex-sv.ts
