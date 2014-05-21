import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Dialog {
    id: root
    objectName: "CreateCommandPage"

    property ShellExecutor modeller

    allowedOrientations: Orientation.All

    SilicaFlickable {

        anchors.fill: parent

        contentHeight: content.height

        Column {
            id: content

            width: parent.width

            DialogHeader {
                title: qsTr("New command")
                acceptText: runOnCreateSwitch.checked ? qsTr("Create and run") : qsTr("Create and save")
            }

            TextField {
                id: nameField
                width: parent.width
                label: qsTr("Entry name (unique)")
                placeholderText: label
            }

            TextArea {
                id: editField
                width: parent.width
                label: qsTr("Command to run")
                placeholderText: label

                inputMethodHints: Qt.ImhNoAutoUppercase
            }

            ComboBox {
                id: runnerChooser

                label: qsTr("Run this command")

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

            TextSwitch {
                id: runOnCreateSwitch
                text: qsTr("Run on create")
                checked: true
            }

            Separator {
                width: parent.width-2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter

                wrapMode: Text.WordWrap

                horizontalAlignment: Text.AlignHCenter

                text: qsTr("Parameter setup coming soon...")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge

            }

        }

    }

    onAccepted: {

        routineLib.createStoredCommand(nameField.text, editField.text,
                                       "SingleLiner", runnerChooser.currentItem.value,
                                       100, runOnCreateSwitch.checked);

    }

}

