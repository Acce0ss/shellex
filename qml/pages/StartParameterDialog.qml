import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

import "../components"

Dialog {
  id: root
  objectName: "CreateCommandPage"

  property ShellCommand command

  allowedOrientations: Orientation.All

  SilicaFlickable {

    anchors.fill: parent

    contentHeight: content.height

    Column {
      id: content

      width: parent.width

      DialogHeader {
        title: root.command.name
        acceptText: qsTr("Run")
      }

      ParameterInputs {
        id: inputs
        width: parent.width - 2*Theme.paddingSmall
        parametersInput: JSON.parse(root.command.content).parameters
      }

    }

  }

  onAccepted: {

    routineLib.openOutputPage(root.command, ShellCommand.UseSavedRunner);

    root.command.startProcess(ShellCommand.UseSavedRunner, inputs.parametersOutput);

  }

}
