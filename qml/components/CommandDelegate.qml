import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.shellex 1.0

import "../"

ListItem {

  id: root

  property CommandsStore storage
  property ShellExecutor executor

  contentHeight: infoView.height + 2*Theme.paddingSmall

  z: 10

  CommandInfoView {
    id: infoView
    highlighted: root.highlighted
  }

  onClicked: {
    routineLib.startCommand(model.display);
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
        if(model.display.hasParameters)
        {
          pageStack.push(Qt.resolvedUrl("../pages/StartParameterDialog.qml"),
                         {command: model.display, detachedRun: true})
        }
        else
        {
          model.display.startDetached(ShellCommand.UseSavedRunner);
        }
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
          pageStack.push(Qt.resolvedUrl("../pages/EditCommandPage.qml"), {command: model.display,
                           modeller: root.executor,
                           editAsNew: false});
        }
      }
    }
    MenuItem {
      text: qsTr("Edit as New")
      onClicked: {
        if(model.display.type === ShellCommand.SingleLiner)
        {
          pageStack.push(Qt.resolvedUrl("../pages/EditCommandPage.qml"), {command: model.display,
                           modeller: root.executor,
                           editAsNew: true});
        }
      }
    }
    MenuItem {
      text: model.display !== null ?
              (model.display.isRunning ? qsTr("Stop") : qsTr("Remove")) : ""
      onClicked: {
        if(model.display !== null)
        {
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
  }

  ListView.onRemove: animateRemoval(root)

  function remove() {
    remorseAction(qsTr("Deleting"), function() {
      commandsStore.removeCommand(model.display)}
    );
  }
}
