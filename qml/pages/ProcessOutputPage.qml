import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Page {
    id: root

    property ShellCommand command

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy to clipboard")
                onClicked: {
                    Clipboard.text = command.output;
                }
            }
        }

        Column {
            id: content

            width: parent.width

            PageHeader {
                title: qsTr("Output")
            }

            Label {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                wrapMode: Text.WordWrap
                text: command.output
                font.pixelSize: Theme.fontSizeTiny
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: Qt.application.active && command.isRunning
            }
        }

        VerticalScrollDecorator {}
    }

}
