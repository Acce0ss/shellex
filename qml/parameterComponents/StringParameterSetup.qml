import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
  id: root

  width: parent.width
  spacing: Theme.paddingMedium

  property string pluginDescription: qsTr("Parameter for general strings")

  property bool acceptableInputs: defaultValueInput.acceptableInput &&
                                  parameterDescriptionInput.acceptableInput

  property var detailsObject: {"defaultValue": defaultValueInput.text,
                               "description": parameterDescriptionInput.text}

  function initializeSetup(obj)
  {
    if(obj.hasOwnProperty("defaultValue"))
    {
      defaultValueInput.text = obj.defaultValue;
    }

    if(obj.hasOwnProperty("description"))
    {
      parameterDescriptionInput.text = obj.description;
    }
  }

  TextField {

    id: defaultValueInput

    width: parent.width

    validator: notEmptyValidator
    label: qsTr("Default value")
    placeholderText: label
  }

  TextField {

    id: parameterDescriptionInput

    width: parent.width

    validator: RegExpValidator {
      id: notEmptyValidator
      regExp: /^\S+.*$/
    }

    label: qsTr("Parameter description")
    placeholderText: label
  }


}
