import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Item {

    anchors.fill: parent
    anchors.leftMargin: Theme.paddingLarge
    anchors.rightMargin: Theme.paddingLarge
    anchors.horizontalCenter: parent.horizontalCenter

    Flickable {
        id: commandFlick
        height: parent.height*0.5
        width: parent.width

        anchors.left: parent.left
        anchors.top: parent.top

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
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: parent.height*0.5
        width: parent.width

        Item {

            id: dateLabels

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: parent.width*0.4

            Label {
                id: dateCreatedLabel
                anchors.top: parent.top
                height: parent.height*0.5

                text: qsTr("Created %1").arg(routineLib.timeSince(model.display.createdOn))
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }

            Label {
                anchors.bottom: parent.bottom
                height: parent.height*0.5

                text: qsTr("Last run %1").arg(routineLib.timeSince(model.display.lastRunOn))
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }
        }

        Item {

            id: runLabels

            anchors.left: dateLabels.right
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: parent.width*0.4

            Label {
                anchors.top: parent.top

                height: parent.height*0.5
                text: qsTr("used %1 times").arg(model.display.runCount)
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }

            Label {
                anchors.bottom: parent.bottom

                height: parent.height*0.5

                property string runner: model.display.runIn === ShellCommand.Fingerterm ?
                                            qsTr("in Fingerterm") : qsTr("inside app")

                text: qsTr("Run %1").arg(runner)
                font.pixelSize: Theme.fontSizeTiny
                color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
            }
        }

        Item {
            anchors.left: runLabels.right
            anchors.rightMargin: Theme.paddingLarge*2
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
    }

}
