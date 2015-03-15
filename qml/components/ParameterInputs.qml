import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
  id: root

  width: parent.width

  property alias parametersInput: parametersModel.parameters
  property alias parametersOutput: parametersModel.outputParams

  Repeater {
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width
    model: parametersModel

    Column {
      width:parent.width
      SectionHeader {
        text: qsTr("Parameter $%1").arg(index+1)
      }

      Loader {
        id: inputElement
        width: parent.width

        source: dataObj.filePath

        Connections {
          target: inputElement.item
          onParameterValueChanged: {
            parametersModel.updateParameterValues(index, inputElement.item.parameterValue)
          }
        }

        onLoaded: {
          inputElement.item.initializeParameter(dataObj.details);
        }
      }
    }

  }

  ListModel {
    id: parametersModel

    property var parameters: []
    property var outputParams: []

    function updateAll() {

      clear()
      for (var i=0; i<parameters.length; i++) {

          append({"dataObj": parameters[i]})
      }
    }

    function updateParameterValues(index, value)
    {
      outputParams[index] = value.toString();
    }

    Component.onCompleted: updateAll()
  }
}
