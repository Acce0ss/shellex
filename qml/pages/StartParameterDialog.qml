import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.shellex 1.0

import "../components"

Dialog {
  id: root
  objectName: "StartParameterDialog"

  property ShellCommand command
  property bool detachedRun: false


  allowedOrientations: Orientation.All

  SilicaFlickable {

    anchors.fill: parent

    contentHeight: content.height

    ScrollDecorator {}

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
        parametersInput: JSON.parse(root.command.content).hasOwnProperty('parameters') ?
                      JSON.parse(root.command.content).parameters : []
      }

    }

  }
  property bool noOutputPage: detachedRun ||
                              root.command.runIn === ShellCommand.Fingerterm
  acceptDestination: noOutputPage ? mainPage
                                  : Qt.resolvedUrl("ProcessOutputPage.qml")
  acceptDestinationAction: noOutputPage ? PageStackAction.Pop
                                        : PageStackAction.Replace
  acceptDestinationProperties: noOutputPage ? {} : {command: command, storageReference: commandsStore}

  onAccepted: {
    if(root.detachedRun)
    {
      root.command.startDetached(ShellCommand.UseSavedRunner, inputs.parametersOutput);
    }
    else
    {
      root.command.startProcess(ShellCommand.UseSavedRunner, inputs.parametersOutput);
    }
  }
}
