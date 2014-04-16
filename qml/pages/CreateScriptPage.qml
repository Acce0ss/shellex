import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Dialog {
    id: root

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
                id: editField
                width: parent.width
            }

        }

    }

    onAccepted: {

    }

    Component.onCompleted: {
        editField.text = root.command.content;
    }
}
