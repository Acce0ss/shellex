import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

import "../components"

Page {
    id: root

    property ShellExecutor shell

    allowedOrientations: Orientation.All

    function focusInput() {
        quickCommand.forceActiveFocus();
    }

    SilicaFlickable {

        id: rootFlickable

        anchors.fill: parent

        contentHeight: contentColumn.height

        pressDelay: 0

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings / About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GlobalSettingsPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Close all running commands")
                onClicked: {
                    shell.stopAllCommands();
                }
            }

            MenuItem {

                property string sorter: sortPage.sortName

                text: qsTr("Sort by: %1").arg(sorter)

                onClicked: {
                    pageStack.push(sortPage);
                }
                SortPage {
                    id: sortPage
                }
            }

            MenuItem {
                text: qsTr("New command")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("CreateCommandPage.qml"), {modeller: root.shell});
                }
            }
        }

        Column {
            id: contentColumn

            width: parent.width

            PageHeader {
                id: pageTitle
                visible: !((root.orientation === Orientation.Landscape) ||
                         (root.orientation === Orientation.LandscapeInverted))
                title: qsTr("Shell Commands")
            }

            ComboBox {
                id: runnerChooser

                label: qsTr("Run quick command")

                menu: ContextMenu {

                    MenuItem{
                        text: qsTr("inside the app")
                        property int value: ShellCommand.InsideApp
                    }

                    MenuItem{
                        enabled: shell.fingertermInstalled
                        text: qsTr("in Fingerterm")
                        property int value: ShellCommand.Fingerterm
                        Label {
                            visible: !parent.enabled
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Fingerterm is not installed")
                            font.pixelSize: Theme.fontSizeTiny
                            color: Theme.secondaryColor
                        }
                    }

                }
            }

            SearchField {
                id: quickCommand

                width: parent.width
                placeholderText: qsTr("Quick command ...")

                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase

                Keys.onReturnPressed: {

                    routineLib.createStoredCommand(quickCommand.text, quickCommand.text,
                                                "SingleLiner", runnerChooser.currentItem.value, 100, true);

                    quickCommand.text = "";
                }

                onTextChanged: {
                    shell.reloadCommandsModel(quickCommand.text);
                }

                validator: RegExpValidator {
                    regExp: /^(?=.*\S).+$/
                }

            }


            SilicaListView {

                id: commandsView

                height: root.height - quickCommand.height
                        - (pageTitle.visible ? pageTitle.height : 0) - runnerChooser.height
                width: parent.width

                pressDelay: 0

                clip: true

                //prevent searchfield from losing focus on model update
                currentIndex: -1

                model: shell.commandsModel

                spacing: Theme.paddingMedium

                delegate: CommandDelegate {

                    id: shortcutItem

                    executor: shell
                    storage: commandsStore

                }

                ViewPlaceholder {
                    anchors.centerIn: parent
                    text: qsTr("No commands to show yet")
                }

                VerticalScrollDecorator {}
            }

        }
    }

    onStatusChanged: {
        if(status === PageStatus.Active)
        {
            commandsView.pressDelay = 0;
            rootFlickable.pressDelay = 0;
        }
    }
}
