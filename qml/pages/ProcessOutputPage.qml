import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

import "../"

Page {
    id: root

    objectName: "ProcessOutputPage"

    property ShellCommand command

    property CommandsStore storageReference

    allowedOrientations: Orientation.All

    function updateCommandHider() {

        if(root.status === PageStatus.Active)
        {
            var updateObj = root.command.getAsJSONObject();
            storageReference.updateCommandLastRunAndCount(updateObj);
        }
    }

    SilicaListView {
        id: outputList
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Clear all")
                onClicked: {
                    command.output.clear();
                }
            }
            MenuItem {
                text: qsTr("Copy all to clipboard")
                onClicked: {
                    Clipboard.text = command.output.outputString;
                }
            }
        }

        header: Column {
            id: content

            width: parent.width

            PageHeader {
                title: qsTr("Output")
            }

        }

        footer: BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: Qt.application.active && command.isRunning
        }

        model: command.output

        spacing: Theme.paddingMedium

        delegate: Component {
            ListItem {
                id: listItem

                height: itemLabel.height
                contentHeight: itemLabel.height

                ListView.onRemove: animateRemoval(listItem)

                Label {
                    id: itemLabel
                    anchors.centerIn: parent
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.rightMargin: Theme.paddingLarge

                    width: parent.width - 2*Theme.paddingLarge

                    wrapMode: Text.WordWrap
                    text: model.display
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor

                    font.pixelSize: Theme.fontSizeTiny
                }

                onClicked: Clipboard.text = model.display;

            }
        }

        VerticalScrollDecorator {}
    }

    onStatusChanged: {
        if(root.status === PageStatus.Active)
        {
           // outputList.scrollToBottom();
        }
    }

}
