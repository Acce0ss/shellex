import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

import "../components"

Dialog {
  id: root
  objectName: "CreateCommandPage"

  property ShellExecutor modeller

  allowedOrientations: Orientation.All

  SilicaFlickable {

    anchors.fill: parent

    contentHeight: content.height

    ScrollDecorator {}

    Column {
      id: content

      width: parent.width

      DialogHeader {
        title: qsTr("New command")
        acceptText: runOnCreateSwitch.checked ? qsTr("Create and run") : qsTr("Create and save")
      }

      SectionHeader {
        text: qsTr("Basics")
      }

      TextField {
        id: nameField
        width: parent.width
        label: acceptableInput ? qsTr("Entry name (unique)") : qsTr("Name not unique")
        placeholderText: label

        validator: CommandNameValidator {
          model: root.modeller.commandsModel
        }
      }

      TextArea {
        id: editField
        width: parent.width
        label: qsTr("Command to run")
        placeholderText: label

        inputMethodHints: Qt.ImhNoAutoUppercase
      }

      ComboBox {
        id: runnerChooser

        label: qsTr("Run this command")

        menu: ContextMenu {

          MenuItem{
            text: qsTr("inside the app")
            property int value: ShellCommand.InsideApp
          }

          MenuItem{
            enabled: modeller.fingertermInstalled
            text: qsTr("in Fingerterm")
            property int value: ShellCommand.Fingerterm
            Label {
              visible: !parent.enabled
              anchors.bottom: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
              text: qsTr("Fingerterm is not installed")
              font.pixelSize: Theme.fontSizeTiny
              color: Theme.secondaryColor
            }
          }

        }
      }

      TextSwitch {
        id: runOnCreateSwitch
        text: qsTr("Run on create")
        checked: true
      }

      Separator {
        width: parent.width-2*Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
      }

      SectionHeader {
        font.pixelSize: Theme.fontSizeLarge
        text: qsTr("Parameters")
      }

      ParameterSetup {
        id: parametersSetup
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
      }

    }

  }

  canAccept: parametersSetup.acceptableParameters && nameField.acceptableInput

  property bool needOutputPage: runOnCreateSwitch.checked &&
                                runnerChooser.currentItem.value === ShellCommand.InsideApp

  acceptDestination: needOutputPage ? ( parametersSetup.count ? Qt.resolvedUrl("ProcessOutputPage.qml")
                                                              : Qt.resolvedUrl("ProcessOutputPage.qml"))
                                    : mainPage
  acceptDestinationAction: needOutputPage ? PageStackAction.Replace
                                          : PageStackAction.Pop

  onAccepted: {

    var scriptContent = JSON.stringify({script: editField.text, parameters: parametersSetup.parameters});
    routineLib.createStoredCommand(nameField.text, scriptContent,
                                   "SingleLiner", runnerChooser.currentItem.value,
                                   100, runOnCreateSwitch.checked);

  }

}

