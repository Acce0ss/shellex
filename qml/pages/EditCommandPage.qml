import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Dialog {
    id: root
    objectName: "EditCommandPage"

    property ShellCommand command
    property ShellExecutor modeller

    property bool editAsNew: false

    property int runner: 0

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
        if(editAsNew === true)
        {
            routineLib.createStoredCommand(editField.text, editField.text,
                                           "SingleLiner", root.runner);

        }
        else
        {
            root.command.content = editField.text;
            root.command.name = editField.text;
            commandStore.updateCommand(root.command.getAsJSONObject());
            if(root.modeller.sortType === ShellExecutor.ByName ||
                    root.modeller.sortType === ShellExecutor.ByNameReverse)
            {
                root.modeller.reSortCommmands();
            }
        }
    }

    Component.onCompleted: {
        editField.text = root.command.content;
    }
}
