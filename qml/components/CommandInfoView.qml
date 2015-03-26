import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

Item {
  id: root

  anchors.horizontalCenter: parent.horizontalCenter

  height: commandFlick.height + infoLabels.height
  width: parent.width-2*Theme.paddingLarge

  state: (orientation === Orientation.Portrait || orientation === Orientation.PortraitInverted )
         ? "portrait"
         : "landscape"

  Flickable {
    id: commandFlick
    height: desc.height+Theme.paddingSmall
    width: parent.width

    anchors.left: parent.left
    anchors.top: parent.top

    pressDelay: 0

    contentWidth: desc.width
    flickableDirection: Flickable.HorizontalFlick

    clip: true

    z: 1


    Label {
      id: desc

      anchors.verticalCenter: parent.verticalCenter


      height: paintedHeight
      text: model.display.name
      color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
      truncationMode: TruncationMode.Fade
    }

  }


  Item {
    id: infoLabels
    anchors.top: commandFlick.bottom
    anchors.left: parent.left
    height: 2*dateLastRunLabel.paintedHeight + Theme.paddingSmall
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

        text: qsTr("Created %1").arg(routineLib.timeSince(model.display.createdOn))
        font.pixelSize: Theme.fontSizeTiny
        color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
      }

      Label {
        id: dateLastRunLabel
        anchors.bottom: parent.bottom
        height: paintedHeight

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
        id: timesUsedLabel
        anchors.top: parent.top
        height: paintedHeight

        text: qsTr("used %1 times").arg(model.display.runCount)
        font.pixelSize: Theme.fontSizeTiny
        color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
      }

      Label {
        id: runnerLabel
        anchors.bottom: parent.bottom
        height: paintedHeight

        property string runner: model.display.runIn === ShellCommand.Fingerterm ?
                                  qsTr("in Fingerterm") : qsTr("inside app")

        text: qsTr("Run %1").arg(runner)
        font.pixelSize: Theme.fontSizeTiny
        color: root.highlighted ? Theme.highlightColor : Theme.secondaryColor
      }
    }

    Item {
      id: runIndicatorContainer
      anchors.left: runLabels.right
      anchors.rightMargin: Theme.paddingLarge*2
      width: runIndicator.width
      height: runIndicator.height+Theme.paddingSmall
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

  states: [

    State {
      name: "portrait"

      PropertyChanges {
        target: infoLabels
        height: 2*dateLastRunLabel.paintedHeight + Theme.paddingSmall
      }
      PropertyChanges {
        target: dateLabels
        width: parent.width*0.4
      }
      PropertyChanges {
        target: dateLabels
        width: parent.width*0.4
      }

      AnchorChanges {
        target: runnerLabel
        anchors.top: undefined
        anchors.bottom: parent.bottom
        anchors.right: undefined
        anchors.left: parent.left
      }
      PropertyChanges {
        target: runnerLabel
        anchors.rightMargin: 0
      }
      AnchorChanges {
        target: dateLastRunLabel
        anchors.top: undefined
        anchors.bottom: parent.bottom
        anchors.right: undefined
        anchors.left: parent.left
      }
      PropertyChanges {
        target: dateLastRunLabel
        anchors.rightMargin: 0
      }
    },
    State {
      name: "landscape"

      PropertyChanges {
        target: infoLabels
        height: dateLastRunLabel.paintedHeight + Theme.paddingSmall
      }

      PropertyChanges {
        target: dateLabels
        width: dateLastRunLabel.implicitWidth+dateCreatedLabel.implicitWidth + 2*Theme.paddingLarge
      }
      PropertyChanges {
        target: runLabels
        width: runnerLabel.implicitWidth+timesUsedLabel.implicitWidth + 2*Theme.paddingLarge
      }

      AnchorChanges {
        target: runnerLabel
        anchors.top: parent.top
        anchors.bottom: undefined
        anchors.right: parent.right
        anchors.left: undefined
      }

      PropertyChanges {
        target: runnerLabel
        anchors.rightMargin: Theme.paddingLarge
      }

      AnchorChanges {
        target: dateLastRunLabel
        anchors.top: parent.top
        anchors.bottom: undefined
        anchors.right: parent.right
        anchors.left: undefined
      }
      PropertyChanges {
        target: dateLastRunLabel
        anchors.rightMargin: Theme.paddingLarge
      }
    }


  ]

}
