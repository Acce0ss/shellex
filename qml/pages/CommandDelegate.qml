import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

import "../"


ListItem {

    id: root

    property int processUsed
    property CommandsStore storage
    property ShellExecutor executor

    contentHeight: Theme.itemSizeLarge // two line delegate

    z: 10

    Column {

        height: parent.contentHeight
        width: parent.width-Theme.paddingLarge*2
        anchors.horizontalCenter: parent.horizontalCenter

        Row {
            spacing: Theme.paddingLarge

            height: parent.height*0.5
            width: parent.width*0.8

            Flickable {
                height: parent.height
                width: parent.width*0.8

                pressDelay: 0

                contentWidth: desc.width
                flickableDirection: Flickable.HorizontalFlick

                clip: true

                z: 1

                Label {
                    anchors.verticalCenter: parent.verticalCenter

                    id: desc
                    text: model.display.name
                    color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }

            }
            Item {
                width: runIndicator.width
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    visible: runIndicator.running
                    anchors.centerIn: parent

                    height: runIndicator.height
                    width: runIndicator.height

                    opacity: 0.5

                    source: "../images/running.png"
                    fillMode: Image.PreserveAspectFit
                }
                BusyIndicator {
                    id: runIndicator
                    anchors.centerIn: parent
                    running: Qt.application.active && model.display.isRunning
                    size: BusyIndicatorSize.Small
                    z: 1
                }
            }
            Label {
                width: parent.width*0.2
                text: qsTr("used\n%1 times").arg(model.display.runCount)
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }
        }

        Label {
            id: dateCreatedLabel

            text: qsTr("Created on %1").arg(model.display.createdOn.toLocaleString(undefined, Locale.ShortFormat))
            font.pixelSize: Theme.fontSizeTiny
            color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
        }

        Label {

            text: qsTr("Last run on %1").arg(model.display.lastRunOn.toLocaleString(undefined, Locale.ShortFormat))
            font.pixelSize: Theme.fontSizeTiny
            color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
        }

    }

    onClicked: {
        if(model.display.isRunning === false)
        {
            model.display.startProcess(root.processUsed);
        }

        pageStack.push(Qt.resolvedUrl("ProcessOutputPage.qml"), {command: model.display, storageReference: storage});
        pageStack.currentPage.statusChanged.connect(pageStack.currentPage.updateCommandHider);

    }

    onPressedChanged: {
        if(pressed === true)
        {
            Qt.inputMethod.hide();
            quickCommand.focus = false;
        }

    }

    menu: ContextMenu {
        enabled: true

        MenuItem {
            text: qsTr("Run detached")
            onClicked: {
                model.display.startDetached(root.processUsed);
            }
            Label {
                visible: parent.enabled
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("State and output will be unavailable")
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
            }

        }


        MenuItem {
            text: qsTr("Edit")
            onClicked: {
                if(model.display.type === ShellCommand.SingleLiner)
                {
                    pageStack.push(Qt.resolvedUrl("EditCommandPage.qml"), {command: model.display,
                                                                           modeller: root.executor,
                                                                           editAsNew: false,
                                                                           runner: runnerChooser.currentItem.value});
                }
            }
        }
        MenuItem {
            text: qsTr("Edit as New")
            onClicked: {
                if(model.display.type === ShellCommand.SingleLiner)
                {
                    pageStack.push(Qt.resolvedUrl("EditCommandPage.qml"), {command: model.display,
                                                                           modeller: root.executor,
                                                                           editAsNew: true,
                                                                           runner: runnerChooser.currentItem.value});
                }
            }
        }
        MenuItem {
            text: model.display.isRunning ? qsTr("Stop") : qsTr("Remove")
            onClicked: {
                if(model.display.isRunning)
                {
                    model.display.stopProcess();
                }
                else
                {
                    root.remove();
                }
            }
        }
    }

    ListView.onRemove: animateRemoval(root)

    function remove() {
        remorseAction(qsTr("Deleting"), function() {
            commandsStore.removeCommand(model.display.getAsJSONObject())}
        );
    }
}
