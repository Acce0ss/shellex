import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
  id: root

  width: parent.width

  property alias parameters: parametersModel.parameters
  property alias count: parametersModel.count
  property bool acceptableParameters: _acceptableParameterCount >= count

  property int _acceptableParameterCount: 0

  Repeater {
    id: paramDisplayer
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width
    model: parametersModel

    Column {
      width:parent.width
      SectionHeader {
        text: qsTr("Parameter $%1").arg(index+1)
      }

      Loader {
        id: setupElement
        width: parent.width

        source: dataObj.setupFilePath

        Connections {
          target: setupElement.item
          onDetailsObjectChanged: {
            parametersModel.updateParameterDetails(index, setupElement.item.detailsObject);
          }
          onAcceptableInputsChanged: {
            if(setupElement.item.acceptableInputs)
            {
              root._acceptableParameterCount++;
            }
            else
            {
              root._acceptableParameterCount--;
            }
          }
        }

        onLoaded: {
          setupElement.item.initializeSetup(dataObj.details);
        }
      }

      Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Remove this parameter")
        onClicked: parametersModel.removeParameter(index)
      }
    }

  }

  Button {
    anchors.horizontalCenter: parent.horizontalCenter
    text: qsTr("Add parameter")
    onClicked: pageStack.push(Qt.resolvedUrl("../pages/ParameterAddPage.qml"), {model: parametersModel})
  }

  ListModel {
    id: parametersModel

    property var parameters: []

    function updateAll() {

      clear()
      for (var i=0; i<parameters.length; i++) {

          append({"dataObj": parameters[i]})
      }
    }

    function updateParameterDetails(index, detailsObj)
    {
      parameters[index].details = detailsObj;
      console.log("Updated details of param " + index + " to " + JSON.stringify(parameters[index].details))
    }

    function removeParameter(index)
    {
      parameters.splice(index, 1);
      remove(index);
    }

    function addParameter(paramObj)
    {
      parameters.push(paramObj);
      append({"dataObj":paramObj})
    }

    Component.onCompleted: updateAll()
  }
}

