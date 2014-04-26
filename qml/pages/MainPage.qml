import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

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

//            MenuItem {
//                text: "New Script"
//            }
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

                label: qsTr("Run ")

                menu: ContextMenu {
                    MenuItem{
                        text: qsTr("in Fingerterm")
                        property int value: ShellExecutor.Fingerterm
                    }
                    MenuItem{
                        text: qsTr("as app child process")
                        property int value: ShellExecutor.Script
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
                                                "SingleLiner", runnerChooser.currentItem.value);

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

                    processUsed: runnerChooser.currentItem.value

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
