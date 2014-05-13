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

    property bool wrapModeOn: wrapSwitch.checked

    onWrapModeOnChanged: {
        if(!wrapModeOn)
        {
            var widestChildWidth = 0;
            for(var i = 0; i < outputList.count; i++)
            {
                var child = outputList.itemAt(i);
                if(child.width > widestChildWidth )
                {
                    widestChildWidth = child.width;
                }
            }
            content.maxLabelLength = widestChildWidth;
        }
    }

    Drawer {
        id: drawer

        anchors.fill: parent
        dock: root.isPortrait ? Dock.Top : Dock.Left

        background: SilicaFlickable {
            anchors.fill: parent
            PullDownMenu {
                id: pulleyMenu

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

            Column {
                width: parent.width
                PageHeader {
                    id: pageTitle
                    width: parent.width
                    title: qsTr("Output")
                }
                NumberOfLinesField {
                    command: root.command
                }
                TextSwitch {
                    id: wrapSwitch
                    text: qsTr("Wrap text")
                }
            }
            VerticalScrollDecorator { }
        }

        SilicaFlickable {

            anchors.fill: parent

            contentHeight: content.height
            contentWidth: content.width

            Column {
                id: content

                property int maxLabelLength: root.width

                width: (root.wrapModeOn) ? root.width : (maxLabelLength + 2*Theme.paddingLarge)

                Button {
                    width: content.width
                    text: drawer.open ? qsTr("Hide options") : qsTr("Show options")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        drawer.open = !drawer.open;
                    }
                }

                Repeater {
                    id: outputList

                    model: command.output

                    delegate: Component {
                        BackgroundItem {
                            id: listItem

                            x: Theme.paddingLarge

                            height: itemLabel.height
                            contentHeight: itemLabel.height
                            width: (root.wrapModeOn || pulleyMenu.active) ? (root.width - 2*Theme.paddingLarge)
                                                                          : (itemLabel.width)

                            onWidthChanged: {
                                if(width > content.maxLabelLength)
                                {
                                    content.maxLabelLength = width;
                                }
                            }

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
    }
    InteractionHintLabel {
        id: hintLabel
        anchors.bottom: parent.bottom
        visible: false
        Behavior on opacity { FadeAnimation { duration: 500 } }
        text: qsTr("Swipe around to see whole output")
    }
    TouchInteractionHint {
        id: horizontalFlick
        direction: TouchInteraction.Left
        loops: Animation.Infinite
        anchors.verticalCenter: parent.verticalCenter
    }

    Timer {
        id: hintTimer
        interval: 4000
        repeat: false
        onTriggered: {
            hintLabel.opacity = 0;
            horizontalFlick.stop();
        }
    }

    onStatusChanged: {
        if(root.status === PageStatus.Active &&
                !root.command.updatedOnThisStart)
        {
            root.storageReference.updateCommandLastRunAndCount(root.command);
            root.command.updatedOnThisStart = true;
        }
    }

    Component.onCompleted: {
        wrapSwitch.checked = false;

        if(globalSettings.timesHintShown <= 3)
        {
            horizontalFlick.start();
            hintLabel.visible = true;
            globalSettings.timesHintShown++;
            hintTimer.running = true;
        }
    }
}
