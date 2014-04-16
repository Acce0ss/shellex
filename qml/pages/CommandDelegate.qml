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
                    text: modelData.name
                    color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
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
                    running: Qt.application.active && modelData.isRunning
                    size: BusyIndicatorSize.Small
                    z: 1
                }
            }
            Label {
                width: parent.width*0.2
                text: qsTr("used\n%1 times").arg(modelData.runCount)
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }
        }

        Label {
            id: dateCreatedLabel

            text: qsTr("Created on %1").arg(modelData.createdOn.toLocaleString(undefined, Locale.ShortFormat))
            font.pixelSize: Theme.fontSizeTiny
            color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
        }

        Label {

            text: qsTr("Last run on %1").arg(modelData.lastRunOn.toLocaleString(undefined, Locale.ShortFormat))
            font.pixelSize: Theme.fontSizeTiny
            color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
        }

    }

    onClicked: {
        if(modelData.isRunning === false)
        {
            modelData.startProcess(root.processUsed);

            storage.updateCommandLastRunAndCount(modelData.getAsJSONObject());

            if(root.processUsed === ShellExecutor.Script)
            {
                pageStack.push(Qt.resolvedUrl("ProcessOutputPage.qml"), {command: modelData});
            }
        }
        else
        {
            pageStack.push(Qt.resolvedUrl("ProcessOutputPage.qml"), {command: modelData});
        }
        if(executor.sortType === ShellExecutor.ByNewestRun ||
                executor.sortType === ShellExecutor.ByOldestRun ||
                executor.sortType === ShellExecutor.ByLeastRuns ||
                executor.sortType === ShellExecutor.ByMostRuns ||
                executor.sortType === ShellExecutor.ByIsRunning)
        {
            executor.reSortCommands();
        }
    }
    menu: ContextMenu {
        enabled: true

        MenuItem {
            text: qsTr("Edit")
            onClicked: {
                if(modelData.type === ShellCommand.SingleLiner)
                {
                    pageStack.push(Qt.resolvedUrl("EditCommandPage.qml"), {command: modelData,
                                                                           modeller: root.executor,
                                                                           editAsNew: false,
                                                                           runner: runnerChooser.currentItem.value});
                }
            }
        }
        MenuItem {
            text: qsTr("Edit as New")
            onClicked: {
                if(modelData.type === ShellCommand.SingleLiner)
                {
                    pageStack.push(Qt.resolvedUrl("EditCommandPage.qml"), {command: modelData,
                                                                           modeller: root.executor,
                                                                           editAsNew: true,
                                                                           runner: runnerChooser.currentItem.value});
                }
            }
        }
        MenuItem {
            text: modelData.isRunning ? qsTr("Stop") : qsTr("Remove")
            onClicked: {
                if(modelData.isRunning)
                {
                    modelData.stopProcess();
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
            commandsStore.removeCommand(modelData.getAsJSONObject())}
        );
    }
}
