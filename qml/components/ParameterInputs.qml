import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
  id: root

  width: parent.width

  property alias parametersInput: parametersModel.parameters
  property alias parametersOutput: parametersModel.outputParams

  property alias count: parametersModel.count
  property bool acceptableInputs: _acceptableInputCount >= count

  property int _acceptableInputCount: 0

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
          onAcceptableInputsChanged: {
            if(inputElement.item.acceptableInputs)
            {
              root._acceptableInputCount++;
              if(root._acceptableInputCount > root.count)
              {
                root._acceptableInputCount = root.count;
              }
            }
            else
            {
              root._acceptableInputCount--;
              if(root._acceptableInputCount < 0)
              {
                root._acceptableInputCount = 0;
              }
            }
          }
        }

        onLoaded: {
          inputElement.item.initializeParameter(dataObj.details);
          inputElement.item.acceptableInputsChanged();
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
