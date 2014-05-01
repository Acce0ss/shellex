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

    property bool wrapModeOn: true

    SilicaFlickable {

        anchors.fill: parent

        contentHeight: content.height
        contentWidth: content.width

        flickableDirection: root.wrapModeOn ? Flickable.VerticalFlick : Flickable.HorizontalAndVerticalFlick

        PullDownMenu {
            id: pulleyMenu

            MenuItem {
                text: qsTr("Clear all")
                onClicked: {
                    command.output.clear();
                }
            }
            MenuItem {
                text: root.wrapModeOn ? qsTr("Don't wrap text") : qsTr("Wrap text")
                onClicked: {
                    root.wrapModeOn = !root.wrapModeOn;
                }
            }
            MenuItem {
                text: qsTr("Copy all to clipboard")
                onClicked: {
                    Clipboard.text = command.output.outputString;
                }
            }
        }

        Column {
            id: content

            width: childrenRect.width

            PageHeader {
                id: pageTitle
                width: parent.width
                title: qsTr("Output")
            }

            Repeater {
                id: outputList

                model: command.output

                delegate: Component {
                    ListItem {
                        id: listItem

                        x: Theme.paddingLarge

                        height: itemLabel.height
                        contentHeight: itemLabel.height
                        width: (root.wrapModeOn || pulleyMenu.active) ? (root.width - 2*Theme.paddingLarge)
                                               : (itemLabel.width)

                        ListView.onRemove: animateRemoval(listItem)

                        Label {
                            id: itemLabel
                            anchors.centerIn: parent

                            width: (root.wrapModeOn || pulleyMenu.active) ? parent.width : implicitWidth

                            wrapMode: root.wrapModeOn ? Text.WordWrap : Text.NoWrap
                            text: model.display
                            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor

                            font.pixelSize: Theme.fontSizeTiny
                            font.family: 'monospace'
                        }

                        onClicked: Clipboard.text = model.display;
                    }
                }
            }
            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: Qt.application.active && command.isRunning
            }
        }
        ScrollDecorator {}
    }

    onStatusChanged: {
        if(root.status === PageStatus.Active &&
                !root.command.updatedOnThisStart)
        {
            root.storageReference.updateCommandLastRunAndCount(root.command);
            root.command.updatedOnThisStart = true;

        }
    }
}
