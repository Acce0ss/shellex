import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Dialog {
    id: root
    objectName: "EditCommandPage"

    property ShellCommand command
    property ShellExecutor modeller

    property bool editAsNew: false

    allowedOrientations: Orientation.All

    SilicaFlickable {

        anchors.fill: parent

        contentHeight: content.height

        Column {
            id: content

            width: parent.width

            DialogHeader {
                title: root.editAsNew ? qsTr("New command") : qsTr("Edit command")
                acceptText: root.editAsNew ? qsTr("Create and run") : qsTr("Save")
            }

            TextField {
                id: nameField
                width: parent.width
                label: qsTr("Entry name (unique)")
            }

            TextField {
                id: editField
                width: parent.width
                label: qsTr("Command to run")
            }

            ComboBox {
                id: runnerChooser

                label: qsTr("Run this command")


                Component.onCompleted: {
                    var currentRunner = root.command.runIn;
                    if(currentRunner === ShellCommand.Fingerterm)
                    {
                        currentIndex = 1;
                    }
                    else if(currentRunner === ShellCommand.InsideApp)
                    {
                        currentIndex = 0;
                    }
                }

                menu: ContextMenu {

                    MenuItem{
                        text: qsTr("inside the app")
                        property int value: ShellCommand.InsideApp
                    }

                    MenuItem{
                        enabled: modeller.fingertermInstalled
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

        }

    }

    onAccepted: {
        if(editAsNew === true)
        {
            routineLib.createStoredCommand(nameField.text, editField.text,
                                           "SingleLiner", runnerChooser.currentItem.value,
                                           command.output.linesMax);

        }
        else
        {
            root.command.content = editField.text;
            root.command.name = nameField.text;
            root.command.runIn = runnerChooser.currentItem.value;
            commandsStore.updateCommand(root.command);

        }
    }

    Component.onCompleted: {
        nameField.text = root.command.content;
        editField.text = root.command.content;
    }
}
