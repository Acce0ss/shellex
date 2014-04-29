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
        if(editAsNew === true)
        {
            var newObj = {name: editField.text, content: editField.text,
                createdOn: new Date().getTime()/1000, lastRunOn: new Date().getTime()/1000,
                type: "SingleLiner"};

            var created = commandStore.addCommand(newObj);
            if(created !== null)
            {
                created.startProcess(runnerChooser.currentItem.value);

                if(runnerChooser.currentItem.value === ShellCommand.InsideApp)
                {
                    pageStack.push(Qt.resolvedUrl("ProcessOutputPage.qml"),
                                   {command: root.modeller.getCommandNamed(newObj.name)});
                }
            }
            else
            {
                console.log("errorz")
            }

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
